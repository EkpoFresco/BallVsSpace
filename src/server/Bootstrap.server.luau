--!strict
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Shared = ReplicatedStorage.Shared
local Math = require(Shared.TerritoryMath)
local Protocol = require(Shared.Protocol)
local Match = require(script.Parent.Services.MatchService)
local Court = require(script.Parent.Services.CourtService)
local Profiles = require(script.Parent.Services.ProfileService)
local Queue = require(script.Parent.Services.QueueService)
local Replication = require(script.Parent.Services.ReplicationService)
Players.CharacterAutoLoads = false
Court.build()
local remotes = Instance.new("Folder")
remotes.Name = "Remotes"
local function remote(name: string): RemoteEvent
	local r = Instance.new("RemoteEvent")
	r.Name = name
	r.Parent = remotes
	return r
end
local command = remote("ClientCommand")
local stateRemote = remote("MatchState")
local territoryRemote = remote("TerritoryUpdate")
local snapshotRequest = remote("SnapshotRequest")
local ack = remote("CommandAck")
local motion = Instance.new("UnreliableRemoteEvent")
motion.Name = "MotionSnapshot"
motion.Parent = remotes
remotes.Parent = ReplicatedStorage
type Gate = {
	tokens: number,
	last: number,
	actions: number,
	aim: number,
	join: number,
	snapshot: number,
	lastId: number,
	ready: boolean,
	rejected: number,
}
local gates: { [Player]: Gate } = {}
local current: Match.State? = nil
local reservations: { Queue.Entry } = {}
local lastState = -1
local lastTerritory = -1
local lastMotion = -1
local lastFull = 0
local finalized = false
local completed = 0
local function sendLobby(p: Player)
	stateRemote:FireClient(p, {
		phase = if Queue.position(p.UserId) then "Queued" else "Lobby",
		persistence = "Session only — prototype",
	})
end
local function add(p: Player)
	gates[p] = {
		tokens = 30,
		last = os.clock(),
		actions = 0,
		aim = 0,
		join = 0,
		snapshot = 0,
		lastId = 0,
		ready = false,
		rejected = 0,
	}
	Profiles.load(p.UserId)
	local m = current
	if m then
		for _, s in m.seats do
			if s.userId == p.UserId then
				s.disconnectedAt = nil
				m.stateVersion += 1
			end
		end
	end
end
Players.PlayerAdded:Connect(add)
for _, p in Players:GetPlayers() do
	add(p)
end
Players.PlayerRemoving:Connect(function(p)
	Queue.cancel(p.UserId)
	gates[p] = nil
	local m = current
	local inMatch = false
	if m then
		for _, s in m.seats do
			if s.userId == p.UserId then
				s.disconnectedAt = Workspace:GetServerTimeNow()
				inMatch = true
			end
		end
	end
	if not inMatch then
		Profiles.release(p.UserId)
	end
end)
local function participant(m: Match.State, p: Player): boolean
	for _, s in m.seats do
		if s.userId == p.UserId then
			return true
		end
	end
	return false
end
local function full(p: Player, m: Match.State)
	stateRemote:FireClient(p, Replication.stateFor(m, p.UserId))
	territoryRemote:FireClient(p, m.id, m.roundId, Replication.full(m))
	motion:FireClient(p, m.id, m.roundId, Protocol.motion(m.sim.balls, m.sim.tick))
end
snapshotRequest.OnServerEvent:Connect(function(p)
	local g = gates[p]
	if not g then
		return
	end
	local now = os.clock()
	if now - g.snapshot < 1 then
		return
	end
	g.snapshot = now
	local m = current
	if m and participant(m, p) then
		full(p, m)
	else
		sendLobby(p)
	end
end)
command.OnServerEvent:Connect(function(p, raw: unknown)
	local g = gates[p]
	if not g then
		return
	end
	local now = os.clock()
	g.tokens = math.min(30, g.tokens + (now - g.last) * 20)
	g.last = now
	if g.tokens < 1 then
		g.rejected += 1
		return
	end
	g.tokens -= 1
	local c = Protocol.command(raw)
	if not c then
		g.rejected += 1
		return
	end
	if c.id <= g.lastId then
		ack:FireClient(p, c.id, false, "duplicate")
		return
	end
	g.lastId = c.id
	local interval = if c.kind == "Aim"
		then 0.1
		elseif c.kind == "Queue" or c.kind == "Practice" then 1
		else 0.2
	local stamp = if c.kind == "Aim"
		then g.aim
		elseif c.kind == "Queue" or c.kind == "Practice" then g.join
		else g.actions
	if now - stamp < interval then
		g.rejected += 1
		ack:FireClient(p, c.id, false, "rate")
		return
	end
	if c.kind == "Aim" then
		g.aim = now
	elseif c.kind == "Queue" or c.kind == "Practice" then
		g.join = now
	else
		g.actions = now
	end
	local accepted = false
	local m = current
	if c.kind == "Ready" then
		g.ready = true
		accepted = true
		if m and participant(m, p) then
			full(p, m)
		else
			sendLobby(p)
		end
	elseif m and participant(m, p) then
		accepted = Match.command(m, p.UserId, c, Workspace:GetServerTimeNow())
	elseif g.ready and c.matchId == "" and c.roundId == 0 and c.generation == 0 then
		if c.kind == "Queue" or c.kind == "Practice" then
			accepted = Queue.join(p.UserId, Workspace:GetServerTimeNow(), c.kind == "Practice")
			sendLobby(p)
		elseif c.kind == "Cancel" then
			Queue.cancel(p.UserId)
			accepted = true
			sendLobby(p)
		end
	end
	ack:FireClient(p, c.id, accepted, if accepted then "ok" else "invalid_state")
end)
RunService.Heartbeat:Connect(function(dt)
	local now = Workspace:GetServerTimeNow()
	if not current then
		local entries = Queue.take()
		if entries then
			reservations = entries
			local users = {}
			for _, e in entries do
				table.insert(users, e.userId)
			end
			local practice = #users == 1
			if practice then
				table.insert(users, -999999)
			end
			local id = HttpService:GenerateGUID(false)
			local prepared = true
			for _, e in entries do
				if not Profiles.prepare(e.userId, id) then
					prepared = false
				end
			end
			if prepared then
				current = Match.new(id, users, math.floor(now * 1000) % 1000000, now, practice)
				lastState = -1
				lastTerritory = -1
				lastMotion = -1
				lastFull = 0
				finalized = false
			else
				for _, e in entries do
					Profiles.complete(e.userId, id)
					local p = Players:GetPlayerByUserId(e.userId)
					if p then
						sendLobby(p)
					end
				end
			end
		end
		return
	end
	local m = current
	local ready = true
	for _, s in m.seats do
		if s.userId ~= -999999 then
			local p = Players:GetPlayerByUserId(s.userId)
			if not p or not gates[p] or not gates[p].ready then
				ready = false
			end
		end
	end
	if m.practice then
		local bot = m.seats[2]
		if m.phase == "Draft" and now - m.entered > 1 then
			bot.kitId = if m.roundNumber % 2 == 1 then "Anchor" else "Drift"
			bot.pickLocked = true
			bot.interactedDraft = true
		elseif m.phase == "Aim" and now - m.entered > 1 then
			bot.angle = if m.roundNumber % 2 == 1 then 155 else 25
			bot.aimLocked = true
			bot.interactedAim = true
		end
	end
	local ok, err = pcall(function()
		Match.update(m, now, dt, ready)
		return "ok"
	end)
	if not ok then
		warn("BVS runtime failure", err)
		Match.finish(m, 0, "simulation_error", now)
	end
	local changed = m.stateVersion ~= lastState
	local grid = m.territorySerial ~= lastTerritory
	local moving = m.sim.tick ~= lastMotion and grid
	local forceFull = now - lastFull >= 2 or changed or m.territorySerial - lastTerritory > 1
	for _, p in Players:GetPlayers() do
		if participant(m, p) and gates[p] and gates[p].ready then
			if changed then
				stateRemote:FireClient(p, Replication.stateFor(m, p.UserId))
			end
			if grid or forceFull then
				territoryRemote:FireClient(
					p,
					m.id,
					m.roundId,
					Protocol.territory(
						m.board,
						m.lastChanges,
						m.lastBase,
						m.sim.tick - m.sim.tick % 6,
						forceFull
					)
				)
			end
			if moving or changed then
				motion:FireClient(p, m.id, m.roundId, Protocol.motion(m.sim.balls, m.sim.tick))
			end
		end
	end
	lastState = m.stateVersion
	lastTerritory = m.territorySerial
	if moving then
		lastMotion = m.sim.tick
	end
	if forceFull then
		lastFull = now
	end
	if RunService:IsStudio() then
		Workspace:SetAttribute("BVSPhase", m.phase)
		Workspace:SetAttribute("BVSTick", m.sim.tick)
		Workspace:SetAttribute("BVSBoardHash", Math.hash(m.board.q))
		Workspace:SetAttribute("BVSCountA", m.board.counts[1])
		Workspace:SetAttribute("BVSCountB", m.board.counts[2])
		Workspace:SetAttribute("BVSMatchId", m.id)
		Workspace:SetAttribute("BVSResultReason", m.reason)
	end
	if m.resultLocked and not finalized then
		finalized = true
		completed += 1
		Workspace:SetAttribute("BVSCompletedMatches", completed)
		print("BVS MATCH_RESULT", m.id, m.reason, m.winner, m.points2[1], m.points2[2], Math.hash(m.board.q))
		for _, e in reservations do
			Profiles.complete(e.userId, m.id)
		end
	end
	if m.resultLocked and now >= m.deadline then
		local unanimous = true
		for _, s in m.seats do
			if s.userId ~= -999999 and not m.rematch[s.userId] then
				unanimous = false
			end
		end
		for _, e in reservations do
			local p = Players:GetPlayerByUserId(e.userId)
			if p then
				if m.reason == "cancelled_before_start" then
					Queue.returnEntry(e)
				elseif unanimous or m.rematch[e.userId] then
					Queue.join(e.userId, now, e.practice)
				end
				sendLobby(p)
			else
				Profiles.release(e.userId)
			end
		end
		current = nil
		Workspace:SetAttribute("BVSPhase", "Lobby")
	end
end)
print("BVS SERVER READY — session-only M1, no purchases")
