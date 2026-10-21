--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config)
local Heroes = require(Shared.HeroDefinitions)
local Types = require(Shared.Types)
local Weapon = require(Shared.WeaponGeometry)
local Protocol = require(Shared.Protocol)
local Combat = require(script.Parent.Parent.Services.CombatService)
local Sim = require(script.Parent.Parent.Services.SimService)
local Territory = require(script.Parent.Parent.Services.TerritoryService)
local Match = require(script.Parent.Parent.Services.MatchService)
local Suite = {}
local function setHp(b: Types.Ball, hp: number)
	local w = b.weapon :: Types.WeaponState
	w.hp = hp
end
local function ball(id: number, kit: string, x: number, z: number): Types.Ball
	local b: Types.Ball = {
		id = id,
		userId = id,
		team = id,
		kitId = kit,
		x = x,
		z = z,
		vx = 0,
		vz = 18,
		speed = 18,
		brush = 0,
		nextAbilityTick = 240,
		effectEndTick = 0,
		lastDx = 0,
		lastDz = 1,
	}
	Combat.initialize(b)
	return b
end
function Suite.run(): { string }
	local passed: { string } = {}
	local function check(name: string, fn: () -> ())
		fn()
		table.insert(passed, name)
		print("BVS PASS " .. name)
	end
	check("30 original heroes, finite bounded geometry, different kits", function()
		assert(#Heroes.ids == 30, "Roster size")
		local seen: { [string]: boolean } = {}
		for _, id in Heroes.ids do
			assert(not seen[id], "Duplicate hero")
			seen[id] = true
			local w = Weapon.new(0, 0, 0)
			for tick = 0, 720 do
				w.omega = Weapon.angularSpeed(id, w, tick)
				w.angle += w.omega / 60
				w.spin += math.abs(w.omega) / 60
				for _, edge in Weapon.sample(id, 0, 0, 1, w, tick) do
					assert(edge.radius > 0 and edge.radius <= 3 and edge.strength <= 2, "Footprint bounds")
					assert(Protocol.finite(edge.ax) and Protocol.finite(edge.bz), "Finite geometry")
				end
			end
		end
	end)
	check("charge timing ignores starting side and snapshot tick matches resolved grid", function()
		for _, id in { "Astra", "Bram", "Edda", "Veyra", "Rook" } do
			local left, right = Weapon.new(0, 0, 0), Weapon.new(0, 0, math.pi)
			for tick = 0, 480, 7 do
				left.spin = tick / 60 * Heroes.heroes[id].rps * 2 * math.pi
				right.spin = left.spin
				local a, b = Weapon.sample(id, 0, 0, 1, left, tick), Weapon.sample(id, 0, 0, 2, right, tick)
				for i, edge in a do
					assert(
						math.abs(edge.ax + b[i].ax) < 1e-6
							and math.abs(edge.bz + b[i].bz) < 1e-6
							and edge.strength == b[i].strength,
						"Side changes charge timing"
					)
				end
			end
		end
		local m = Match.new("snapshot-tick", { 1, 2 }, 1, 0, false)
		Match.beginRound(m, 0)
		m.sim.tick = 5
		local Replication = require(script.Parent.Parent.Services.ReplicationService)
		assert(
			buffer.readu32(Replication.full(m), 9) == 0,
			"Snapshot labels unprocessed territory as current"
		)
	end)
	check("body travel is inert; only weapon contact paints", function()
		local board = Territory.new()
		Territory.resolve(board, { { ax = -20, az = 0, bx = 20, bz = 0, team = 1, radius = 8 } }, {})
		assert(board.counts[0] == 1024, "Body brush survived")
		local b = ball(1, "Astra", -10, 0)
		local sim = Sim.new({ b })
		local shapes: { Types.Shape } = {}
		Combat.step(sim, shapes)
		Territory.resolve(board, {}, shapes)
		assert(board.counts[1] > 0, "Weapon failed to paint")
		local index = 16 * 32 + 11
		assert(buffer.readi8(board.q, index) == 0, "Body/shaft painted")
	end)
	check("multi-head hits share rearm; friendly bodies take no damage", function()
		local a, b = ball(1, "Nerio", 0, 0), ball(2, "Oren", 9, 0)
		local w = b.weapon :: Types.WeaponState
		w.angle = math.pi / 2
		local sim = Sim.new({ a, b })
		local effects: { Types.Shape } = {}
		Combat.step(sim, effects)
		assert(w.hp == 87, "Trident should hit once, not once per tine")
		local hp = w.hp
		for _ = 1, 5 do
			Combat.step(sim, effects)
		end
		assert(w.hp == hp, "Continuous contact duplicated hit")
		a = ball(1, "Nerio", 0, 0)
		b = ball(2, "Oren", 9, 0)
		b.team = 1
		sim = Sim.new({ a, b })
		Combat.step(sim, {})
		assert((b.weapon :: Types.WeaponState).hp == 100, "Friendly fire")
	end)
	check("simultaneous damage and no lethal healing", function()
		local a, b = ball(1, "Astra", 0, 0), ball(2, "Astra", 9, 0)
		setHp(a, 10)
		setHp(b, 10)
		Combat.step(Sim.new({ a, b }), {})
		assert(
			(a.weapon :: Types.WeaponState).hp == 0 and (b.weapon :: Types.WeaponState).hp == 0,
			"Seat order changed double KO"
		)
		a = ball(1, "Runa", 0, 0)
		b = ball(2, "Astra", 8, 0)
		setHp(a, 10)
		Combat.step(Sim.new({ a, b }), {})
		assert((a.weapon :: Types.WeaponState).hp == 0, "Healing rescued lethal damage")
	end)
	check("dead heroes have no motion or future weapon footprint", function()
		local b = ball(1, "Bram", 0, 0)
		local w = b.weapon :: Types.WeaponState
		w.hp = 0
		local sim = Sim.new({ b })
		local shapes: { Types.Shape } = {}
		Combat.step(sim, shapes)
		assert(b.x == 0 and b.z == 0 and #shapes == 0, "Dead hero moved or painted")
	end)
	check("KO flushes partial tick once and locks damage, score and points", function()
		local m = Match.new("partial", { 1, 2 }, 1, 0, false)
		Match.beginRound(m, 0)
		m.phase = "Battle"
		m.hasStarted = true
		m.sim = Sim.new({ ball(1, "Astra", 0, 0), ball(2, "Astra", 9, 0) })
		setHp(m.sim.balls[2], 1)
		Match.update(m, 1, 1 / 60, true)
		assert(
			m.roundLocked and m.reason == "knockout" and m.sim.tick == 1,
			"KO did not resolve on impact tick"
		)
		local version = m.board.version
		local points = m.points2[1] + m.points2[2]
		Match.update(m, 1.1, 0.1, true)
		assert(
			m.board.version == version and m.sim.tick == 1 and m.points2[1] + m.points2[2] == points,
			"Post-KO mutation"
		)
	end)
	check("weapon pose and HP packet round trip, finite rejection", function()
		local b = ball(1, "Iria", 0, 0)
		local w = b.weapon :: Types.WeaponState
		w.angle = 8 * math.pi + 0.2
		w.hp = 37
		w.omega = -7
		local payload = Protocol.motion({ b }, 901)
		local decoded, tick = Protocol.decodeMotion(payload)
		assert(
			decoded
				and tick == 901
				and decoded[1].weapon.hp == 37
				and math.abs(decoded[1].weapon.angle - w.angle) < 0.00001,
			"Lost authoritative weapon state"
		)
		buffer.writef32(payload, 5 + 33, 0 / 0)
		assert(Protocol.decodeMotion(payload) == nil, "NaN phase accepted")
	end)
	check("all heroes finish a bounded combat simulation without body pressure", function()
		for i, id in Heroes.ids do
			local a, b = ball(1, id, -12, -4), ball(2, Heroes.ids[(i + 12) % 30 + 1], 12, 4)
			a.vx = 18
			a.vz = 0
			b.vx = -18
			b.vz = 0
			local sim = Sim.new({ a, b })
			local board = Territory.new()
			local effects: { Types.Shape } = {}
			for _ = 1, 180 do
				Combat.step(sim, effects)
				if sim.tick % Config.TerritoryEvery == 0 then
					Territory.resolve(board, {}, effects)
					table.clear(effects)
				end
				table.clear(sim.paths)
			end
			assert(
				sim.recoveries <= 3 and board.counts[0] + board.counts[1] + board.counts[2] == 1024,
				"Hero simulation invariant"
			)
			task.wait()
		end
	end)
	return passed
end
return table.freeze(Suite)
