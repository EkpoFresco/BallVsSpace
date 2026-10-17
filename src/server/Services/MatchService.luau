--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local Arena = require(Shared.ArenaDefinition)
local Catalog = require(Shared.BallCatalog)
local Config = require(Shared.Config)
local Draft = require(Shared.SeededDraft)
local Rules = require(Shared.RoundRules)
local Types = require(Shared.Types)
local Ability = require(script.Parent.AbilityService)
local Analytics = require(script.Parent.AnalyticsService)
local Sim = require(script.Parent.SimService)
local Territory = require(script.Parent.TerritoryService)
export type Seat = {
	userId: number,
	team: number,
	offer: { string },
	kitId: string,
	angle: number,
	pickLocked: boolean,
	aimLocked: boolean,
	wildcardUsed: boolean,
	tentativeWildcard: boolean,
	interactedDraft: boolean,
	interactedAim: boolean,
	inactiveRounds: number,
	disconnectedAt: number?,
}
export type State = {
	id: string,
	seed: number,
	practice: boolean,
	phase: string,
	generation: number,
	roundId: number,
	roundNumber: number,
	deadline: number,
	entered: number,
	started: number,
	now: number,
	seats: { Seat },
	points2: { number },
	board: Types.Board,
	sim: Sim.State,
	effects: { Types.Shape },
	hold: Rules.Hold,
	accumulator: number,
	debtSince: number?,
	roundLocked: boolean,
	resultLocked: boolean,
	hasStarted: boolean,
	winner: number,
	reason: string,
	stateVersion: number,
	lastChanges: { Types.Change },
	lastBase: number,
	territorySerial: number,
	trace: { Analytics.Event },
	replay: { { tick: number, q: buffer, motion: buffer } },
	rematch: { [number]: boolean },
}
local Match = {}
local function transition(m: State, phase: string, now: number, duration: number)
	m.phase = phase
	m.generation += 1
	m.entered = now
	m.deadline = now + duration
	m.stateVersion += 1
	Analytics.record(m.trace, "phase", m.sim.tick, m.board.counts[1], m.board.counts[2], phase)
end
function Match.beginRound(m: State, now: number)
	m.roundNumber += 1
	m.roundId += 1
	m.roundLocked = false
	m.board = Territory.new()
	m.effects = {}
	m.hold = { leader = 0, updates = 0 }
	m.accumulator = 0
	m.debtSince = nil
	m.replay = {}
	local balls: { Types.Ball } = {}
	for i, seat in m.seats do
		seat.offer = Draft.offers(m.seed, m.roundNumber, 1, Catalog.ids)
		seat.kitId = seat.offer[1]
		seat.pickLocked = false
		seat.aimLocked = false
		seat.tentativeWildcard = false
		seat.interactedDraft = false
		seat.interactedAim = false
		local x, z = Arena.spawn(seat.team, 1, m.roundNumber, 1)
		seat.angle = if x < 0 then 0 else 180
		local kit = Catalog.kits[seat.kitId]
		table.insert(balls, {
			id = i,
			userId = seat.userId,
			team = seat.team,
			kitId = seat.kitId,
			x = x,
			z = z,
			vx = 0,
			vz = 0,
			speed = kit.speed,
			brush = kit.brushRadius,
			nextAbilityTick = kit.firstReadyTick,
			effectEndTick = 0,
			lastDx = if x < 0 then 1 else -1,
			lastDz = 0,
		})
	end
	m.sim = Sim.new(balls)
	Territory.seed(m.board, balls)
	m.territorySerial += 1
	m.lastBase = 0
	m.lastChanges = {}
	transition(m, "Draft", now, Config.DraftSeconds)
end
function Match.new(id: string, users: { number }, seed: number, now: number, practice: boolean): State
	local seats: { Seat } = {}
	for i, userId in users do
		table.insert(seats, {
			userId = userId,
			team = i,
			offer = {},
			kitId = "Drift",
			angle = 0,
			pickLocked = false,
			aimLocked = false,
			wildcardUsed = false,
			tentativeWildcard = false,
			interactedDraft = false,
			interactedAim = false,
			inactiveRounds = 0,
			disconnectedAt = nil,
		})
	end
	local m: State = {
		id = id,
		seed = seed,
		practice = practice,
		phase = "ReadyCheck",
		generation = 0,
		roundId = 0,
		roundNumber = 0,
		deadline = now + 5,
		entered = now,
		started = now,
		now = now,
		seats = seats,
		points2 = { 0, 0 },
		board = Territory.new(),
		sim = Sim.new({}),
		effects = {},
		hold = { leader = 0, updates = 0 },
		accumulator = 0,
		debtSince = nil,
		roundLocked = false,
		resultLocked = false,
		hasStarted = false,
		winner = 0,
		reason = "",
		stateVersion = 0,
		lastChanges = {},
		lastBase = 0,
		territorySerial = 0,
		trace = {},
		replay = {},
		rematch = {},
	}
	return m
end
function Match.finish(m: State, winner: number, reason: string, now: number)
	if m.resultLocked then
		return
	end
	m.resultLocked = true
	m.winner = winner
	m.reason = reason
	transition(m, "MatchResult", now, 8)
	Analytics.record(m.trace, "match_finished", m.sim.tick, m.points2[1], m.points2[2], reason)
end
function Match.lockRound(m: State, winner: number, now: number)
	if m.roundLocked then
		return
	end
	m.roundLocked = true
	m.winner = winner
	m.reason = if winner == 0 then "overtime_draw" else "final_area"
	if winner == 0 then
		m.points2[1] += 1
		m.points2[2] += 1
	else
		m.points2[winner] += 2
	end
	for _, seat in m.seats do
		seat.inactiveRounds = if not seat.interactedDraft and not seat.interactedAim
			then seat.inactiveRounds + 1
			else 0
	end
	transition(m, "RoundResult", now, 3)
	Analytics.record(m.trace, "round_finished", m.sim.tick, m.board.counts[1], m.board.counts[2], m.reason)
end
function Match.command(m: State, userId: number, c: Types.Command, now: number): boolean
	if c.matchId ~= m.id or c.roundId ~= m.roundId or c.generation ~= m.generation then
		return false
	end
	local seat: Seat? = nil
	for _, s in m.seats do
		if s.userId == userId then
			seat = s
			break
		end
	end
	if not seat then
		return false
	end
	if c.kind == "Leave" and not m.resultLocked then
		Match.finish(
			m,
			if m.hasStarted then 3 - seat.team else 0,
			if m.hasStarted then "voluntary_forfeit" else "cancelled_before_start",
			now
		)
		return true
	end
	if c.kind == "Rematch" and m.phase == "MatchResult" then
		m.rematch[userId] = true
		return true
	end
	if now >= m.deadline then
		return false
	end
	if m.phase == "Draft" and not seat.pickLocked then
		if c.kind == "Select" and c.kitId and Catalog.kits[c.kitId] then
			local offered = table.find(seat.offer, c.kitId) ~= nil
			if not offered and (not c.wildcard or seat.wildcardUsed) then
				return false
			end
			seat.kitId = c.kitId
			seat.tentativeWildcard = not offered
			seat.interactedDraft = true
			m.stateVersion += 1
			return true
		elseif c.kind == "Commit" then
			if seat.tentativeWildcard then
				if seat.wildcardUsed then
					return false
				end
				seat.wildcardUsed = true
			end
			seat.pickLocked = true
			seat.interactedDraft = true
			m.stateVersion += 1
			return true
		end
	elseif m.phase == "Aim" and not seat.aimLocked then
		if c.kind == "Aim" and c.angle then
			seat.angle = math.floor(c.angle + 0.5) % 360
			seat.interactedAim = true
			m.stateVersion += 1
			return true
		elseif c.kind == "AimLock" then
			seat.aimLocked = true
			seat.interactedAim = true
			m.stateVersion += 1
			return true
		end
	end
	return false
end
function Match.update(m: State, now: number, dt: number, ready: boolean)
	m.now = now
	if m.resultLocked then
		return
	end
	local expired = { [1] = false, [2] = false }
	for _, s in m.seats do
		if s.disconnectedAt then
			if not m.hasStarted then
				Match.finish(m, 0, "cancelled_before_start", now)
				return
			end
			if now - s.disconnectedAt >= 15 then
				expired[s.team] = true
			end
		end
	end
	if expired[1] or expired[2] then
		Match.finish(
			m,
			if expired[1] and expired[2] then 0 elseif expired[1] then 2 else 1,
			if expired[1] and expired[2] then "both_teams_disconnected" else "disconnect_forfeit",
			now
		)
		return
	end
	if now - m.started >= 240 then
		Match.finish(m, 0, "service_timeout", now)
		return
	end
	if m.phase == "ReadyCheck" then
		if ready then
			Match.beginRound(m, now)
		elseif now >= m.deadline then
			Match.finish(m, 0, "ready_timeout", now)
		end
	elseif m.phase == "Draft" then
		local locked = true
		for _, s in m.seats do
			if not s.pickLocked then
				locked = false
			end
		end
		if now >= m.deadline or (locked and now - m.entered >= 3) then
			for i, s in m.seats do
				if not s.pickLocked and s.tentativeWildcard then
					s.kitId = s.offer[1]
					s.tentativeWildcard = false
				end
				s.pickLocked = true
				local k = Catalog.kits[s.kitId]
				local b = m.sim.balls[i]
				b.kitId = s.kitId
				b.speed = k.speed
				b.brush = k.brushRadius
				b.nextAbilityTick = k.firstReadyTick
			end
			transition(m, "Aim", now, 8)
		end
	elseif m.phase == "Aim" then
		local locked = true
		for _, s in m.seats do
			if not s.aimLocked then
				locked = false
			end
		end
		if now >= m.deadline or (locked and now - m.entered >= 2) then
			for _, s in m.seats do
				s.aimLocked = true
			end
			m.hasStarted = true
			transition(m, "Countdown", now, 2)
		end
	elseif m.phase == "Countdown" and now >= m.deadline then
		for i, s in m.seats do
			local b = m.sim.balls[i]
			b.vx = math.cos(math.rad(s.angle)) * b.speed
			b.vz = math.sin(math.rad(s.angle)) * b.speed
			b.lastDx = b.vx / b.speed
			b.lastDz = b.vz / b.speed
		end
		m.accumulator = 0
		transition(m, "Battle", now, 30)
	elseif m.phase == "Battle" or m.phase == "Overtime" then
		m.accumulator += dt
		if m.accumulator > 0.5 then
			m.debtSince = m.debtSince or now
		elseif m.debtSince then
			m.debtSince = nil
		end
		if m.debtSince and now - m.debtSince >= 2 then
			Match.finish(m, 0, "simulation_debt", now)
			return
		end
		local steps = 0
		while m.accumulator >= 1 / 60 - 1e-10 and steps < 8 and not m.roundLocked do
			m.accumulator -= 1 / 60
			steps += 1
			Ability.beforeStep(m.sim.tick + 1, m.sim.balls)
			Sim.step(m.sim)
			Ability.afterStep(m.sim.tick, m.sim.balls, m.effects)
			if m.sim.recoveries > 3 then
				Match.finish(m, 0, "simulation_failure", now)
				return
			end
			if m.sim.tick % 6 == 0 then
				m.lastBase = m.board.version
				m.lastChanges = Territory.resolve(m.board, m.sim.paths, m.effects)
				m.territorySerial += 1
				table.clear(m.sim.paths)
				table.clear(m.effects)
				local finished, winner, overtime =
					Rules.evaluate(m.sim.tick, m.board.counts[1], m.board.counts[2], m.hold)
				if finished then
					Match.lockRound(m, winner, now)
				elseif overtime then
					transition(m, "Overtime", now, 15)
				end
			end
		end
	elseif m.phase == "RoundResult" and now >= m.deadline then
		if Rules.matchFinished(m.roundNumber, m.points2[1], m.points2[2]) then
			Match.finish(
				m,
				if m.points2[1] > m.points2[2] then 1 elseif m.points2[2] > m.points2[1] then 2 else 0,
				"match_points",
				now
			)
		else
			local inactive = { [1] = false, [2] = false }
			for _, s in m.seats do
				if s.inactiveRounds >= 2 and s.userId > 0 then
					inactive[s.team] = true
				end
			end
			if inactive[1] or inactive[2] then
				Match.finish(
					m,
					if inactive[1] and inactive[2] then 0 elseif inactive[1] then 2 else 1,
					"inactivity_forfeit",
					now
				)
			else
				Match.beginRound(m, now)
			end
		end
	end
end
return table.freeze(Match)
