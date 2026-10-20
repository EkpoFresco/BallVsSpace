--!strict
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config)
local Appearances = require(Shared.AppearanceCatalog)
local Protocol = require(Shared.Protocol)
local ViewTypes = require(Shared.ViewTypes)
local Match = require(script.Parent.MatchService)
local Replication = {}
function Replication.stateFor(m: Match.State, userId: number): ViewTypes.State
	local seats: { ViewTypes.Seat } = {}
	local localKit = ""
	local localAngle = 0
	local offer = {}
	local wildcard = false
	for i, s in m.seats do
		local player = Players:GetPlayerByUserId(s.userId)
		local own = s.userId == userId
		local b = m.sim.balls[i]
		local revealed = m.phase ~= "Draft" and m.phase ~= "ReadyCheck"
		local aimRevealed = revealed and m.phase ~= "Aim"
		table.insert(seats, {
			id = i,
			userId = s.userId,
			team = s.team,
			name = if player then player.DisplayName else "Practice",
			kitId = if own or revealed then s.kitId else nil,
			appearance = if own or revealed
				then (if Appearances.valid(s.appearance, s.kitId)
					then s.appearance
					else Appearances.default(s.kitId))
				else nil,
			angle = if own or aimRevealed then s.angle else nil,
			pickLocked = s.pickLocked,
			aimLocked = s.aimLocked,
			x = if b then b.x else 0,
			z = if b then b.z else 0,
		})
		if own then
			localKit = s.kitId
			localAngle = s.angle
			offer = table.clone(s.offer)
			wildcard = s.wildcardUsed
		end
	end
	return {
		id = m.id,
		phase = m.phase,
		generation = m.generation,
		roundId = m.roundId,
		roundNumber = m.roundNumber,
		deadline = m.deadline,
		tick = m.sim.tick,
		points2 = table.clone(m.points2),
		winner = m.winner,
		reason = m.reason,
		practice = m.practice,
		seats = seats,
		offer = offer,
		wildcardUsed = wildcard,
		localKit = localKit,
		localAngle = localAngle,
		hold = m.hold.updates,
		holdLeader = m.hold.leader,
		persistence = Config.Persistence,
		rematchRequested = m.rematch[userId] == true,
	}
end
function Replication.full(m: Match.State): buffer
	return Protocol.territory(m.board, {}, 0, m.sim.tick - m.sim.tick % 6, true)
end
return table.freeze(Replication)
