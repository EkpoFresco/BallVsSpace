--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config)
local Heroes = require(Shared.HeroDefinitions)
local Geometry = require(Shared.Geometry2D)
local Types = require(Shared.Types)
local Weapon = require(Shared.WeaponGeometry)
local Sim = require(script.Parent.SimService)
local Combat = {}
function Combat.initialize(ball: Types.Ball)
	ball.weapon = Weapon.new(ball.x, ball.z, if ball.x <= 0 then 0 else math.pi)
	ball.hitAt, ball.touchAt = {}, {}
	ball.healReadyTick = 0
end
function Combat.step(sim: Sim.State, effects: { Types.Shape }): boolean
	local tick = sim.tick + 1
	local starts: { [number]: number } = {}
	for _, b in sim.balls do
		if not b.weapon then
			Combat.initialize(b)
		end
		local w = b.weapon :: Types.WeaponState
		starts[b.id] = w.angle
		if w.hp <= 0 then
			continue
		end
		w.omega = Weapon.angularSpeed(b.kitId, w, tick)
		w.angle += w.omega / 60
		w.spin += math.abs(w.omega) / 60
		if (Weapon.isProjectile(b.kitId) or b.kitId == "Enna") and tick % 240 == 1 then
			w.castTick, w.castAngle, w.castCancelled = tick, w.angle, false
			local reach = if b.kitId == "Enna" then Heroes.heroes[b.kitId].reach else 0
			w.castX, w.castZ = b.x + math.cos(w.angle) * reach, b.z + math.sin(w.angle) * reach
		end
	end
	local first = #sim.paths + 1
	Sim.step(sim)
	local damage: { [number]: number } = {}
	local healing: { [number]: number } = {}
	local power: { [number]: boolean } = {}
	local slow: { [number]: boolean } = {}
	local guards: { [number]: boolean } = {}
	local cancel: { [number]: boolean } = {}
	local turns: { [number]: { x: number, z: number } } = {}
	local touched: { [number]: { [number]: boolean } } = {}
	local landed: { [number]: { [number]: boolean } } = {}
	local function position(id: number, alpha: number): (number, number)
		for n = first, #sim.paths do
			local p = sim.paths[n]
			if p.ballId == id and alpha >= (p.t0 or 0) - 1e-8 and alpha <= (p.t1 or 1) + 1e-8 then
				local t = math.clamp((alpha - (p.t0 or 0)) / math.max(1e-9, (p.t1 or 1) - (p.t0 or 0)), 0, 1)
				return p.ax + (p.bx - p.ax) * t, p.az + (p.bz - p.az) * t
			end
		end
		local b = sim.balls[id]
		return b.x, b.z
	end
	for _, attacker in sim.balls do
		local w = attacker.weapon :: Types.WeaponState
		if w.hp <= 0 then
			continue
		end
		local h = Heroes.heroes[attacker.kitId]
		local hitAt = attacker.hitAt :: { [number]: number }
		local touchAt = attacker.touchAt :: { [number]: number }
		touched[attacker.id], landed[attacker.id] = {}, {}
		for n = first, #sim.paths do
			local p = sim.paths[n]
			if p.ballId ~= attacker.id then
				continue
			end
			local t0, t1 = p.t0 or 0, p.t1 or 1
			local span = t1 - t0
			if span < 1e-8 then
				continue
			end
			-- Each interval follows an actual collision-split path. Angular samples are
			-- bounded to <0.4 studs of tip travel; narrow tips cannot tunnel between ticks.
			local travel = math.sqrt((p.bx - p.ax) ^ 2 + (p.bz - p.az) ^ 2)
				+ math.abs(w.angle - starts[attacker.id]) * 14 * span
				+ 0.7 * span
			local samples = math.max(2, math.ceil(travel / 0.35))
			assert(samples <= 20, "Weapon sampling budget")
			for j = 0, samples do
				local alpha = t0 + span * j / samples
				local x, z = p.ax + (p.bx - p.ax) * j / samples, p.az + (p.bz - p.az) * j / samples
				local pose = table.clone(w)
				pose.angle = starts[attacker.id] + (w.angle - starts[attacker.id]) * alpha
				pose.spin = w.spin - math.abs(w.omega) / 60 * (1 - alpha)
				for _, edge in Weapon.sample(attacker.kitId, x, z, attacker.team, pose, tick - 1 + alpha) do
					if edge.strength > 0 then
						table.insert(effects, edge)
					end
					if edge.damageScale <= 0 then
						continue
					end
					for _, target in sim.balls do
						local tw = target.weapon :: Types.WeaponState
						if target.team == attacker.team or tw.hp <= 0 then
							continue
						end
						local tx, tz = position(target.id, alpha)
						if
							Geometry.distanceSquaredToSegment(tx, tz, edge.ax, edge.az, edge.bx, edge.bz)
							> (Config.Radius + edge.radius) ^ 2
						then
							continue
						end
						touched[attacker.id][target.id] = true
						if
							landed[attacker.id][target.id]
							or tick - (hitAt[target.id] or -1000) < h.cooldown
							or tick - (touchAt[target.id] or -1000) <= 1
						then
							continue
						end
						landed[attacker.id][target.id] = true
						hitAt[target.id] = tick
						local amount = math.floor(h.damage * edge.damageScale + 0.5)
						local th = Heroes.heroes[target.kitId]
						local dx, dz = (edge.ax + edge.bx) / 2 - tx, (edge.az + edge.bz) / 2 - tz
						local length = math.max(1e-6, math.sqrt(dx * dx + dz * dz))
						local guardAngle = tw.angle + math.pi
						if
							th.family == "Guards"
							and target.kitId ~= "Runa"
							and tw.guardReadyTick <= tick
							and not guards[target.id]
							and (dx * math.cos(guardAngle) + dz * math.sin(guardAngle)) / length > 0.35
						then
							guards[target.id] = true
							amount = math.floor(amount * 0.35)
							if target.kitId == "Bori" or target.kitId == "Fen" then
								power[target.id] = true
							end
							if target.kitId == "Cira" and edge.projectile then
								amount = 0
								cancel[attacker.id] = true
							end
						end
						damage[target.id] = (damage[target.id] or 0) + amount
						if amount > 0 then
							if attacker.kitId == "Korra" or attacker.kitId == "Perri" then
								power[attacker.id] = true
							end
							if attacker.kitId == "Vaska" then
								slow[target.id] = true
							end
							if
								attacker.kitId == "Runa"
								and w.hp <= 40
								and (attacker.healReadyTick or 0) <= tick
							then
								healing[attacker.id] = 5
							end
							if attacker.kitId == "Dorrin" or attacker.kitId == "Toren" then
								local sign = if attacker.kitId == "Toren" then -1 else 1
								turns[target.id] = { x = (tx - x) * sign, z = (tz - z) * sign }
							end
						end
					end
				end
			end
		end
	end
	local changed = false
	-- Gather every hit before changing health: a final simultaneous strike is a draw.
	for _, b in sim.balls do
		local w = b.weapon :: Types.WeaponState
		local before = w.hp
		w.hp = math.max(0, w.hp - (damage[b.id] or 0))
		if w.hp > 0 then
			if healing[b.id] then
				w.hp = math.min(100, w.hp + healing[b.id])
				b.healReadyTick = tick + 180
			end
			if power[b.id] then
				w.poweredUntil = tick + 90
			end
			if slow[b.id] then
				w.slowUntil = tick + 60
			end
			if guards[b.id] then
				w.guardReadyTick = tick + 120
			end
			if cancel[b.id] then
				w.castCancelled = true
			end
			local turn = turns[b.id]
			if turn then
				local length = math.sqrt(turn.x ^ 2 + turn.z ^ 2)
				if length > 1e-6 then
					local dx, dz =
						b.vx / b.speed + turn.x / length * 0.6, b.vz / b.speed + turn.z / length * 0.6
					local norm = math.sqrt(dx ^ 2 + dz ^ 2)
					b.vx, b.vz = dx / norm * b.speed, dz / norm * b.speed
				end
			end
		else
			w.omega = 0
			b.vx = 0
			b.vz = 0
		end
		local touches = b.touchAt :: { [number]: number }
		local currentTouches: { [number]: boolean } = touched[b.id] or {}
		for id in currentTouches do
			touches[id] = tick
		end
		changed = changed or before ~= w.hp or guards[b.id] == true or cancel[b.id] == true
	end
	assert(#effects <= 6000, "Weapon footprint budget exceeded")
	return changed
end
return table.freeze(Combat)
