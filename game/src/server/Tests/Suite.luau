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
local Replication = require(script.Parent.Parent.Services.ReplicationService)
local Profile = require(script.Parent.Parent.Services.ProfileService)
local Sim = require(script.Parent.Parent.Services.SimService)
local Territory = require(script.Parent.Parent.Services.TerritoryService)
local History = require(script.Parent.Parent.Services.CommandHistory)
local WeaponTests = require(script.Parent.WeaponSuite)
local Weapon = require(Shared.WeaponGeometry)
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
				kitId = "Astra",
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
		local catalog = { "Astra", "Bram", "Echo", "Prism", "Null", "Seeder", "Skimmer", "Surveyor" }
		for seed = 1, 200 do
			local a = Draft.offers(seed, 2, 1, catalog)
			local b = Draft.offers(
				seed,
				2,
				1,
				{ "Surveyor", "Skimmer", "Seeder", "Null", "Prism", "Echo", "Bram", "Astra" }
			)
			assert(#a == 3 and a[1] ~= a[2] and a[2] ~= a[3] and a[1] ~= a[3], "Three distinct offers")
			assert(table.concat(a) == table.concat(b), "Stable catalog order")
		end
	end)
	check("KO, simultaneous KO, time, area then normalized health", function()
		local m = Match.new("rules", { 1, 2 }, 1, 0, false)
		Match.beginRound(m, 0)
		local balls = m.sim.balls
		balls[1].weapon = Weapon.new(0, 0, 0)
		balls[2].weapon = Weapon.new(0, 0, 0)
		local a, b = balls[1].weapon :: Types.WeaponState, balls[2].weapon :: Types.WeaponState
		local done, winner, reason = Rules.evaluate(Config.BattleTicks - 1, 500, 400, balls)
		assert(not done, "Timer cut off early")
		done, winner, reason = Rules.evaluate(Config.BattleTicks, 501, 500, balls)
		assert(done and winner == 1 and tostring(reason) == "final_area", "One-cell regulation win")
		a.hp = 20
		b.hp = 80
		done, winner, reason = Rules.evaluate(Config.BattleTicks, 500, 500, balls)
		assert(done and winner == 2 and tostring(reason) == "health_tiebreak", "Health tiebreak")
		a.hp = 80
		done, winner, reason = Rules.evaluate(Config.BattleTicks, 500, 500, balls)
		assert(done and winner == 0 and tostring(reason) == "equal_area_health", "Exact draw")
		a.hp = 0
		done, winner, reason = Rules.evaluate(1, 1000, 0, balls)
		assert(done and winner == 2 and tostring(reason) == "knockout", "KO precedes area")
		b.hp = 0
		done, winner, reason = Rules.evaluate(1, 1000, 0, balls)
		assert(done and winner == 0 and tostring(reason) == "double_ko", "Simultaneous KO")
		assert(Rules.matchFinished(3, 3, 3) and Rules.matchFinished(2, 4, 0), "Round points")
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
	check("motion seat identity and bounded acknowledgement replay", function()
		local m = Match.new("protocol", { 1, 2 }, 1, 0, false)
		Match.beginRound(m, 0)
		local payload = Protocol.motion(m.sim.balls, 6)
		assert(Protocol.decodeMotion(payload), "Valid motion")
		buffer.writeu8(payload, 5 + 74, 1)
		assert(Protocol.decodeMotion(payload) == nil, "Duplicate seat must not swap appearance")
		local history = History.new()
		History.record(history, 1, true, "ok")
		History.record(history, 2, false, "rate")
		local accepted, rejected = History.lookup(history, 1), History.lookup(history, 2)
		assert(
			accepted and accepted.accepted and rejected and rejected.reason == "rate",
			"Original acknowledgement"
		)
		for id = 3, 100 do
			History.record(history, id, true, "ok")
		end
		local last = History.lookup(history, 100)
		assert(
			#history.ids == 64 and History.lookup(history, 1) == nil and last and last.accepted,
			"Bounded replay cache"
		)
	end)
	check("incremental grid decode matches full recount and rejects corrupt changes atomically", function()
		local authoritative, decoded = Territory.new(), Territory.new()
		local random = Random.new(20102026)
		for step = 1, 300 do
			local base = authoritative.version
			local changes = {}
			for i = 1, 12 do
				local index = (step * 17 + i * 83) % 1024
				local value = random:NextInteger(-3, 3)
				buffer.writei8(authoritative.q, index, value)
				table.insert(changes, { index = index, q = value })
			end
			authoritative.counts = Math.count(authoritative.q)
			authoritative.version += 1
			local payload = Protocol.territory(authoritative, changes, base, step * 6, step % 20 == 0)
			local nextBoard = Protocol.decodeTerritory(payload, decoded)
			assert(
				nextBoard and buffer.tostring(nextBoard.q) == buffer.tostring(authoritative.q),
				"Full/delta board equivalence"
			)
			assert(
				nextBoard.counts[0] == authoritative.counts[0]
					and nextBoard.counts[1] == authoritative.counts[1]
					and nextBoard.counts[2] == authoritative.counts[2],
				"Incremental counts"
			)
			local oldHash = Math.hash(decoded.q)
			buffer.writeu16(payload, 13, 1025)
			assert(
				Protocol.decodeTerritory(payload, decoded) == nil and Math.hash(decoded.q) == oldHash,
				"Bad totals cannot mutate base"
			)
			decoded = nextBoard
			if step % 50 == 0 then
				task.wait()
			end
		end
		local bad = Protocol.territory(authoritative, {}, 0, 1800, true)
		buffer.writei8(bad, 200, 4)
		assert(Protocol.decodeTerritory(bad, decoded) == nil, "Full invalid influence")
		bad = Protocol.territory(
			authoritative,
			{ { index = 0, q = 1 }, { index = 0, q = -1 } },
			decoded.version,
			1800,
			false
		)
		assert(Protocol.decodeTerritory(bad, decoded) == nil, "Duplicate delta cell")
	end)
	check("wildcard timeout restores appearance and rematch confirmation is authoritative", function()
		local m = Match.new("review", { 1, 2 }, 1, 0, false)
		Match.beginRound(m, 0)
		m.seats[1].offer = { "Astra" }
		assert(
			Match.command(m, 1, {
				id = 1,
				kind = "Select",
				matchId = m.id,
				roundId = m.roundId,
				generation = m.generation,
				kitId = "Bram",
				appearance = "Bram",
				wildcard = true,
			}, 1),
			"Tentative wildcard"
		)
		Match.update(m, m.deadline, 0, true)
		assert(
			m.seats[1].kitId == "Astra" and m.seats[1].appearance == "Astra" and not m.seats[1].wildcardUsed,
			"Timeout restores default appearance with kit"
		)
		Match.finish(m, 1, "match_points", 30)
		local version = m.stateVersion
		local c = { id = 2, kind = "Rematch", matchId = m.id, roundId = m.roundId, generation = m.generation }
		assert(Match.command(m, 1, c, 31), "Rematch accepted")
		assert(
			m.stateVersion == version + 1
				and Replication.stateFor(m, 1).rematchRequested
				and not Replication.stateFor(m, 2).rematchRequested,
			"Confirmation is private and replicated"
		)
		assert(Match.command(m, 1, c, 32) and m.stateVersion == version + 1, "Rematch is idempotent")
		assert(not Match.command(m, 2, c, m.deadline) and not m.rematch[2], "Expired rematch rejected")
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
		assert(
			Match.command(m, 1, {
				id = 2,
				kind = "AimLock",
				matchId = m.id,
				roundId = m.roundId,
				generation = m.generation,
				angle = 314.6,
			}, 3.1),
			"Atomic aim lock"
		)
		assert(m.seats[1].angle == 315 and m.seats[1].aimLocked, "Final direction must accompany lock")
		assert(not Match.command(m, 1, {
			id = 3,
			kind = "Aim",
			matchId = m.id,
			roundId = m.roundId,
			generation = m.generation,
			angle = 20,
		}, 3.2), "Locked direction immutable")
		cmd(2, "AimLock", 3.1)
		Match.update(m, 4.9, 0, true)
		assert(tostring(m.phase) == "Aim", "Aim floor")
		Match.update(m, 5, 0, true)
		Match.update(m, 7, 0, true)
		assert(tostring(m.phase) == "Battle", "Countdown")
		m.sim.tick = Config.BattleTicks - 6
		m.board.q = buffer.create(1024)
		m.board.counts = { [0] = 1024, [1] = 0, [2] = 0 }
		m.sim.balls[1].kitId = "Astra"
		m.sim.balls[1].nextAbilityTick = 1800
		m.sim.balls[2].kitId = "Bram"
		Match.update(m, 37, 0.12, true)
		assert(m.sim.tick == Config.BattleTicks and m.roundLocked, "Cutoff must stop leftover accumulator")
		local before = Math.hash(m.board.q)
		Match.update(m, 37.5, 1, true)
		assert(m.sim.tick == Config.BattleTicks and Math.hash(m.board.q) == before, "No late paint")
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
	for _, name in WeaponTests.run() do
		table.insert(passed, name)
	end
	return passed
end
return table.freeze(Suite)
