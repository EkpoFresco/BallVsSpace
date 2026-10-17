--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local Arena = require(Shared.ArenaDefinition)
local Config = require(Shared.Config)
local Draft = require(Shared.SeededDraft)
local Geometry = require(Shared.Geometry2D)
local Math = require(Shared.TerritoryMath)
local Protocol = require(Shared.Protocol)
local Rules = require(Shared.RoundRules)
local Types = require(Shared.Types)
local Match = require(script.Parent.Parent.Services.MatchService)
local Profile = require(script.Parent.Parent.Services.ProfileService)
local Sim = require(script.Parent.Parent.Services.SimService)
local Territory = require(script.Parent.Parent.Services.TerritoryService)
local Suite = {}
function Suite.run(): { string }
	local passed = {}
	local function check(name: string, fn: () -> ())
		fn()
		table.insert(passed, name)
		print("BVS PASS " .. name)
	end
	check("all cell centers, bounds, mirrored spawn stamp", function()
		for i = 0, 1023 do
			local x, z = Arena.center(i)
			assert(Arena.index(x, z) == i, "Mapping")
		end
		assert(
			Arena.index(32, 0) == nil and Arena.index(-32, -32) == 0 and Arena.index(31.99, 31.99) == 1023,
			"Half-open boundary"
		)
		local m = Match.new("test", { 1, 2 }, 33, 0, false)
		Match.beginRound(m, 0)
		assert(m.board.counts[1] == m.board.counts[2] and m.board.counts[1] > 0, "Symmetric stamps")
		local x, z = Arena.spawn(1, 1, 2, 1)
		assert(x == Config.SpawnX and z == 0, "Side alternation")
		assert(
			math.abs(Config.Radius + Config.CenterBound - Config.HalfSize) < 1e-8,
			"Visible body must touch the wall at collision"
		)
	end)
	check("126 influence cases and four-step reinforced capture", function()
		for q = -3, 3 do
			for a = 0, 2 do
				for b = 0, 2 do
					for d = 0, 1 do
						local nextQ = Math.resolve(q, a, b, d == 1)
						local expected = math.clamp(q - (if d == 1 then math.sign(q) else 0) + a - b, -3, 3)
						assert(
							nextQ == expected and nextQ == -Math.resolve(-q, b, a, d == 1),
							"Influence symmetry"
						)
					end
				end
			end
		end
		local q = 3
		for _, expected in { 2, 1, 0, -1 } do
			q = Math.resolve(q, 0, 1, false)
			assert(q == expected, "Four-step flip")
		end
	end)
	check("maximum pressure, shape order and random full recounts", function()
		local random = Random.new(6183)
		local a, b = Territory.new(), Territory.new()
		for n = 1, 1000 do
			local shapes: { Types.Shape } = {}
			for j = 1, 4 do
				local x, z = random:NextNumber(-32, 32), random:NextNumber(-32, 32)
				table.insert(shapes, {
					ax = x,
					az = z,
					bx = x + 3,
					bz = z + 7,
					radius = random:NextNumber(1, 7),
					team = j % 2 + 1,
					strength = j % 2 + 1,
					drain = n % 11 == 0,
				})
			end
			local reversed = { shapes[4], shapes[3], shapes[2], shapes[1], shapes[1] }
			Territory.resolve(a, {}, shapes)
			Territory.resolve(b, {}, reversed)
			assert(buffer.tostring(a.q) == buffer.tostring(b.q), "Order/nonstacking")
			assert(a.counts[0] + a.counts[1] + a.counts[2] == 1024, "Conservation")
			if n % 100 == 0 then
				task.wait()
			end
		end
	end)
	check("capsule endpoints, tangent, sweep and empty range", function()
		assert(Geometry.distanceSquaredToSegment(0, 3, -2, 0, 2, 0) == 9, "Tangent")
		assert(Geometry.distanceSquaredToSegment(3, 4, 0, 0, 0, 0) == 25, "Zero length")
		assert(Geometry.distanceSquaredToSegment(0, 0, -30, 0, 30, 0) == 0, "Sweep")
		local x0, x1 = Geometry.cellBounds(100, 0, 110, 0, 1)
		assert(x0 > x1, "Empty range")
		assert(Geometry.sweepCircleCircle(4, 0, -60, 0, 3, 1 / 60) ~= nil, "Max speed crossing")
	end)
	check("head-on, glancing, corner, triple, overlapping and bounced paths", function()
		local function ball(id: number, x: number, z: number, vx: number, vz: number): Types.Ball
			local speed = math.sqrt(vx ^ 2 + vz ^ 2)
			return {
				id = id,
				userId = id,
				team = id % 2 + 1,
				kitId = "Drift",
				x = x,
				z = z,
				vx = vx,
				vz = vz,
				speed = speed,
				brush = 4,
				nextAbilityTick = 360,
				effectEndTick = 0,
				lastDx = vx / speed,
				lastDz = vz / speed,
			}
		end
		local r = Config.Radius
		local head = Sim.new({ ball(1, -r - 0.1, 0, 18, 0), ball(2, r + 0.1, 0, -18, 0) })
		Sim.step(head)
		assert(head.balls[1].vx < 0 and head.balls[2].vx > 0, "Elastic exchange")
		local corner = Sim.new({ ball(1, Config.CenterBound - 0.1, Config.CenterBound - 0.1, 18, 18) })
		Sim.step(corner)
		assert(
			corner.balls[1].vx < 0 and corner.balls[1].vz < 0 and #corner.paths >= 2,
			"Corner and path split"
		)
		for _, balls in
			{
				{ ball(1, 0, 0, 18, 0), ball(2, 0, 0, -18, 0) },
				{ ball(1, -2 * r, 0, 18, 0), ball(2, 0, 0, 0, 18), ball(3, 2 * r, 0, -18, 0) },
				{ ball(1, -r - 0.2, 0, 23, 0), ball(2, r + 0.2, r / 2, -18, 0) },
			}
		do
			local s = Sim.new(balls)
			for _ = 1, 120 do
				Sim.step(s)
				table.clear(s.paths)
			end
			assert(s.recoveries <= 3, "Solver repeated recovery")
			for i = 1, #balls do
				for j = i + 1, #balls do
					assert(
						(balls[i].x - balls[j].x) ^ 2 + (balls[i].z - balls[j].z) ^ 2 >= (2 * r - 0.002) ^ 2,
						"Persistent penetration"
					)
				end
			end
		end
	end)
	check("stable, matched, unique three-card drafts", function()
		local catalog = { "Drift", "Anchor", "Echo", "Prism", "Null", "Seeder", "Skimmer", "Surveyor" }
		for seed = 1, 200 do
			local a = Draft.offers(seed, 2, 1, catalog)
			local b = Draft.offers(
				seed,
				2,
				1,
				{ "Surveyor", "Skimmer", "Seeder", "Null", "Prism", "Echo", "Anchor", "Drift" }
			)
			assert(#a == 3 and a[1] ~= a[2] and a[2] ~= a[3] and a[1] ~= a[3], "Three distinct offers")
			assert(table.concat(a) == table.concat(b), "Stable catalog order")
		end
	end)
	check("regulation cutoff, overtime reset, final-boundary hold, cap draw", function()
		local hold = { leader = 0, updates = 0 }
		local finished, winner, ot = Rules.evaluate(1800, 501, 500, hold)
		assert(finished and winner == 1 and not ot, "One-cell regulation win")
		finished, winner, ot = Rules.evaluate(1800, 512, 512, hold)
		assert(not finished and ot, "Exact tie only")
		for tick = 1806, 1860, 6 do
			Rules.evaluate(tick, 501, 500, hold)
		end
		assert(hold.updates == 0, "One-cell margin")
		for tick = 1866, 1914, 6 do
			finished = Rules.evaluate(tick, 502, 500, hold)
			assert(not finished, "Nine updates")
		end
		Rules.evaluate(1920, 501, 500, hold)
		assert(hold.updates == 0, "Reset")
		for tick = 2646, 2700, 6 do
			finished, winner = Rules.evaluate(tick, 500, 502, hold)
		end
		assert(finished and winner == 2, "Final-boundary hold must win")
		finished, winner = Rules.evaluate(2700, 502, 500, { leader = 1, updates = 3 })
		assert(finished and winner == 0, "Unheld cap is draw")
		assert(Rules.matchFinished(3, 3, 3) and Rules.matchFinished(2, 4, 0), "Match points")
	end)
	check("protocol atomicity, invalid buffers, stale delta, finite boundary", function()
		local a, b = Territory.new(), Territory.new()
		local changes = Territory.resolve(
			a,
			{},
			{ { ax = 0, az = 0, bx = 0, bz = 0, team = 1, radius = 6, strength = 2 } }
		)
		local payload = Protocol.territory(a, changes, 0, 6, false)
		local decoded = Protocol.decodeTerritory(payload, b)
		assert(decoded and buffer.tostring(decoded.q) == buffer.tostring(a.q), "Delta decode")
		assert(Protocol.decodeTerritory(payload, decoded) == nil, "Wrong base")
		buffer.writeu16(payload, 17, 2000)
		assert(
			Protocol.decodeTerritory(payload, b) == nil and b.version == 0 and b.counts[0] == 1024,
			"Atomic rejection"
		)
		assert(Protocol.decodeTerritory(buffer.create(3), b) == nil, "Truncated")
		assert(not Protocol.finite(0 / 0) and not Protocol.finite(math.huge), "Finite gate")
		assert(Protocol.command({
			id = 1,
			kind = "Aim",
			matchId = "x",
			roundId = 1,
			generation = 1,
			angle = 0 / 0,
		}) == nil, "NaN input")
		assert(
			Protocol.command({ id = 1, kind = "Aim", matchId = "x", roundId = 1, generation = 1, angle = 360 })
				== nil,
			"Angle bounds"
		)
		assert(
			Protocol.command({ id = 1, kind = "Aim", matchId = "x", roundId = 1, generation = 1, coins = 100 })
				== nil,
			"Unknown keys"
		)
	end)
	check("state deadlines, early floors, late input, and post-result freeze", function()
		local m = Match.new("state", { 1, 2 }, 1, 0, false)
		Match.update(m, 0, 0, true)
		local function cmd(user: number, kind: string, now: number): boolean
			return Match.command(
				m,
				user,
				{ id = 1, kind = kind, matchId = m.id, roundId = m.roundId, generation = m.generation },
				now
			)
		end
		cmd(1, "Commit", 0.1)
		cmd(2, "Commit", 0.1)
		Match.update(m, 2.9, 0, true)
		assert(m.phase == "Draft", "Draft floor")
		Match.update(m, 3, 0, true)
		assert(tostring(m.phase) == "Aim", "Draft transition")
		assert(not cmd(1, "AimLock", m.deadline), "Late input")
		cmd(1, "AimLock", 3.1)
		cmd(2, "AimLock", 3.1)
		Match.update(m, 4.9, 0, true)
		assert(tostring(m.phase) == "Aim", "Aim floor")
		Match.update(m, 5, 0, true)
		Match.update(m, 7, 0, true)
		assert(tostring(m.phase) == "Battle", "Countdown")
		m.sim.tick = 1794
		m.board.q = buffer.create(1024)
		m.board.counts = { [0] = 1024, [1] = 0, [2] = 0 }
		m.sim.balls[1].kitId = "Drift"
		m.sim.balls[1].nextAbilityTick = 1800
		m.sim.balls[2].kitId = "Anchor"
		Match.update(m, 37, 0.12, true)
		assert(m.sim.tick == 1800 and m.roundLocked, "Cutoff must stop leftover accumulator")
		local before = Math.hash(m.board.q)
		Match.update(m, 37.5, 1, true)
		assert(m.sim.tick == 1800 and Math.hash(m.board.q) == before, "No late paint")
		local points = m.points2[1] + m.points2[2]
		Match.lockRound(m, 1, 38)
		assert(m.points2[1] + m.points2[2] == points, "Idempotent round")
	end)
	check("disconnect cancellation, grace, simultaneous abort, fake reward dedup", function()
		local m = Match.new("drop", { 1, 2 }, 1, 0, false)
		m.seats[1].disconnectedAt = 0
		Match.update(m, 1, 0, true)
		assert(m.reason == "cancelled_before_start", "Pre-start cancel")
		m = Match.new("drop2", { 1, 2 }, 1, 0, false)
		m.hasStarted = true
		m.seats[1].disconnectedAt = 0
		m.seats[2].disconnectedAt = 0
		Match.update(m, 15, 0, true)
		assert(tostring(m.reason) == "both_teams_disconnected" and m.winner == 0, "Both teams expire")
		local p = Profile.load(90001)
		assert(Profile.prepare(90001, "reward"), "Prepare")
		Profile.complete(90001, "reward")
		Profile.complete(90001, "reward")
		assert(p.matches == 1, "Dedup")
		Profile.release(90001)
	end)
	return passed
end
return table.freeze(Suite)
