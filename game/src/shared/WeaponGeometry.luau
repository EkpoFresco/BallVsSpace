--!strict
local Heroes = require(script.Parent.HeroDefinitions)
local Types = require(script.Parent.Types)
export type Edge = Types.Shape & { damageScale: number, projectile: boolean, kind: string }
local Weapon = {}
local tau = 2 * math.pi
function Weapon.new(x: number, z: number, angle: number): Types.WeaponState
	return {
		spin = 0,
		hp = 100,
		angle = angle,
		omega = 0,
		poweredUntil = 0,
		slowUntil = 0,
		guardReadyTick = 0,
		castTick = -1000,
		castX = x,
		castZ = z,
		castAngle = angle,
		castCancelled = false,
	}
end
function Weapon.angularSpeed(id: string, w: Types.WeaponState, tick: number): number
	local h = Heroes.heroes[id]
	local rate = h.rps * tau
	local cycle = tick % 240
	if id == "Iria" then
		rate *= if tick % 180 < 15 then 0 else (if tick % 360 < 180 then 1 else -1)
	elseif id == "Mako" then
		rate *= if tick % 120 < 24 then 0.08 else 1.23
	elseif id == "Sola" and math.floor(tick / 90) % 4 == 3 then
		rate *= 0.2
	elseif id == "Zefi" or id == "Kesh" or id == "Pax" then
		rate *= if cycle < 120 then 0.6 else 1.4
	elseif id == "Perri" and w.poweredUntil > tick then
		rate *= 1.5
	end
	if w.slowUntil > tick then
		rate *= 0.7
	end
	return rate
end
function Weapon.isProjectile(id: string): boolean
	return id == "Ravi" or id == "Tavi" or id == "Suri"
end
function Weapon.sample(
	id: string,
	x: number,
	z: number,
	team: number,
	w: Types.WeaponState,
	tick: number
): { Edge }
	local h = Heroes.heroes[id]
	local result: { Edge } = {}
	if w.hp <= 0 then
		return result
	end
	local a, reach, width = w.angle, h.reach, h.width
	local turn = math.floor(w.spin / tau)
	local powered = w.poweredUntil > tick
	local function edge(
		ax: number,
		az: number,
		bx: number,
		bz: number,
		radius: number,
		strength: number,
		damage: number,
		kind: string,
		projectile: boolean?
	)
		table.insert(result, {
			ax = ax,
			az = az,
			bx = bx,
			bz = bz,
			radius = radius,
			team = team,
			strength = strength,
			damageScale = damage,
			kind = kind,
			projectile = projectile == true,
		})
	end
	local function radial(
		angle: number,
		inner: number,
		outer: number,
		radius: number,
		pressure: number,
		damage: number,
		kind: string
	)
		local dx, dz = math.cos(angle), math.sin(angle)
		edge(x + dx * inner, z + dz * inner, x + dx * outer, z + dz * outer, radius, pressure, damage, kind)
	end
	if Weapon.isProjectile(id) then
		local age = tick - w.castTick
		local flight = age >= 0 and age < 120
		if flight and not w.castCancelled then
			local distance = if id == "Suri" then 5 + age * 0.23 else 5 + math.min(age, 60) * 0.3
			for n = 1, (if id == "Tavi" then 2 else 1) do
				local direction = w.castAngle + (n - 1) * math.pi
				local px, pz =
					w.castX + math.cos(direction) * distance, w.castZ + math.sin(direction) * distance
				if age > 60 and id ~= "Suri" then
					local alpha = (age - 60) / 60
					px += (x - px) * alpha
					pz += (z - pz) * alpha
				end
				-- Arena walls absorb flying weapons; no invisible off-board attacks.
				if math.abs(px) <= 32 and math.abs(pz) <= 32 then
					edge(px, pz, px, pz, width, 1, 1, "disc", true)
				end
			end
		elseif not flight then
			radial(a, reach - 0.6, reach, width, 1, 1, "disc")
		end
		return result
	end
	if id == "Astra" and turn % 3 == 2 then
		reach += 2
	end
	if id == "Rook" and turn % 4 == 3 then
		reach += 4
	end
	if id == "Kesh" or id == "Pax" then
		reach = if tick % 240 < 120 then reach else reach * 0.65
	end
	if id == "Korra" and powered then
		width *= 1.6
	end
	local pressure = if (id == "Bram" and turn % 3 == 2)
			or id == "Tala"
			or (id == "Sola" and math.floor(tick / 90) % 4 == 3)
			or ((id == "Bori" or id == "Fen") and powered)
		then 2
		else 1
	local damage = if (id == "Bram" and turn % 3 == 2) or (id == "Fen" and powered) then 1.25 else 1
	if id == "Nerio" then
		for n = -1, 1 do
			radial(
				a + n * 0.20,
				reach - 1.8,
				reach + (if tick % 180 < 30 then 1.5 else 0),
				width,
				pressure,
				damage,
				"blade"
			)
		end
	elseif id == "Mira" then
		local px, pz = x + math.cos(a) * 3.5, z + math.sin(a) * 3.5
		for n = 1, 3 do
			local direction = a + math.sin(tick / 20 - n * 0.7) * 0.5
			local nx, nz = px + math.cos(direction) * 1.8, pz + math.sin(direction) * 1.8
			edge(px, pz, nx, nz, width, pressure, damage, "whip")
			px, pz = nx, nz
		end
	elseif id == "Nix" or id == "Perri" or id == "Edda" then
		for n = 0, 1 do
			local r = if id == "Edda" and turn % 2 == n then reach * 0.65 else reach
			radial(
				a + n * math.pi,
				r - (if id == "Edda" then 0 else 1.2),
				r,
				width,
				pressure,
				damage,
				if id == "Edda" then "weight" else "blade"
			)
		end
	elseif id == "Zefi" then
		local open = tick % 240 < 120
		for n = -1, 1 do
			radial(a + n * (if open then 0.4 else 0.06), 3.6, reach, width, pressure, damage, "blade")
		end
	elseif id == "Veyra" or id == "Toren" or id == "Runa" then
		local spread = if id == "Veyra" and turn % 2 == 0 then 0.45 else 0.22
		for n = 0, 1 do
			local aa, ba = a - spread + n * spread, a + n * spread
			edge(
				x + math.cos(aa) * reach,
				z + math.sin(aa) * reach,
				x + math.cos(ba) * reach,
				z + math.sin(ba) * reach,
				width,
				pressure,
				damage,
				"blade"
			)
		end
	elseif h.family == "Heavy" or h.family == "Chains" then
		local tangent = if id == "Bram" or id == "Korra" then 1.2 else 0.3
		local px, pz = x + math.cos(a) * reach, z + math.sin(a) * reach
		edge(
			px - math.sin(a) * tangent,
			pz + math.cos(a) * tangent,
			px + math.sin(a) * tangent,
			pz - math.cos(a) * tangent,
			width,
			pressure,
			damage,
			"weight"
		)
	else
		radial(
			a,
			if id == "Oren" then reach - 0.7 else math.max(3.6, reach - 2.5),
			reach,
			width,
			pressure,
			damage,
			"blade"
		)
	end
	if h.family == "Guards" and id ~= "Runa" then
		local ga = a + math.pi
		local arc = math.acos(0.35)
		for n = 0, 2 do
			local aa, ba = ga - arc + n * arc * 2 / 3, ga - arc + (n + 1) * arc * 2 / 3
			edge(
				x + math.cos(aa) * 3.8,
				z + math.sin(aa) * 3.8,
				x + math.cos(ba) * 3.8,
				z + math.sin(ba) * 3.8,
				0.6,
				0,
				0,
				"guard"
			)
		end
	end
	if id == "Enna" and tick - w.castTick >= 0 and tick - w.castTick < 90 then
		edge(w.castX, w.castZ, w.castX, w.castZ, 1.5, 2, 0, "seed")
	end
	return result
end
return table.freeze(Weapon)
