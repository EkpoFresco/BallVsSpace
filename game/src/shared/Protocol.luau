--!strict
local Math = require(script.Parent.TerritoryMath)
local Types = require(script.Parent.Types)
local Weapon = require(script.Parent.WeaponGeometry)
local Protocol = {}
local commandFields = table.freeze({
	id = true,
	kind = true,
	matchId = true,
	roundId = true,
	generation = true,
	kitId = true,
	appearance = true,
	angle = true,
	wildcard = true,
})
function Protocol.finite(value: unknown): boolean
	return type(value) == "number" and value == value and math.abs(value) < math.huge
end
function Protocol.command(raw: unknown): Types.Command?
	if type(raw) ~= "table" then
		return nil
	end
	local t = raw :: { [string]: unknown }
	local count = 0
	for key in t do
		count += 1
		if type(key) ~= "string" or not commandFields[key] or count > 9 then
			return nil
		end
	end
	if
		type(t.id) ~= "number"
		or not Protocol.finite(t.id)
		or t.id % 1 ~= 0
		or t.id < 1
		or t.id > 2147483647
	then
		return nil
	end
	if type(t.kind) ~= "string" or #t.kind > 20 or type(t.matchId) ~= "string" or #t.matchId > 80 then
		return nil
	end
	for _, key in { "roundId", "generation" } do
		local n = t[key]
		if type(n) ~= "number" or not Protocol.finite(n) or n % 1 ~= 0 or n < 0 then
			return nil
		end
	end
	if t.kitId ~= nil and (type(t.kitId) ~= "string" or #t.kitId > 24) then
		return nil
	end
	if t.appearance ~= nil and (type(t.appearance) ~= "string" or #t.appearance > 16) then
		return nil
	end
	if
		t.angle ~= nil
		and (type(t.angle) ~= "number" or not Protocol.finite(t.angle) or t.angle < 0 or t.angle >= 360)
	then
		return nil
	end
	if t.wildcard ~= nil and type(t.wildcard) ~= "boolean" then
		return nil
	end
	return (t :: unknown) :: Types.Command
end
function Protocol.territory(
	board: Types.Board,
	changes: { Types.Change },
	base: number,
	tick: number,
	full: boolean
): buffer
	full = full or #changes > 256
	local payload = buffer.create(17 + (if full then 1024 else #changes * 3))
	buffer.writeu8(payload, 0, if full then 1 else 0)
	buffer.writeu32(payload, 1, base)
	buffer.writeu32(payload, 5, board.version)
	buffer.writeu32(payload, 9, tick)
	buffer.writeu16(payload, 13, board.counts[1])
	buffer.writeu16(payload, 15, board.counts[2])
	if full then
		buffer.copy(payload, 17, board.q)
	else
		for n, change in changes do
			local offset = 17 + (n - 1) * 3
			buffer.writeu16(payload, offset, change.index)
			buffer.writei8(payload, offset + 2, change.q)
		end
	end
	return payload
end
function Protocol.decodeTerritory(payload: buffer, board: Types.Board): (Types.Board?, number, string?)
	local length = buffer.len(payload)
	if length < 17 then
		return nil, 0, "length"
	end
	local full = buffer.readu8(payload, 0)
	local base, version, tick =
		buffer.readu32(payload, 1), buffer.readu32(payload, 5), buffer.readu32(payload, 9)
	if
		full > 1
		or (full == 1 and length ~= 1041)
		or (full == 0 and ((length - 17) % 3 ~= 0 or length > 785))
	then
		return nil, 0, "length"
	end
	if version < board.version or (full == 0 and base ~= board.version) then
		return nil, 0, "version"
	end
	local q = buffer.create(1024)
	local counts: { [number]: number }
	if full == 1 then
		buffer.copy(q, 0, payload, 17, 1024)
		counts = { [0] = 0, [1] = 0, [2] = 0 }
		for i = 0, 1023 do
			local value = buffer.readi8(q, i)
			if math.abs(value) > 3 then
				return nil, 0, "influence"
			end
			counts[Math.owner(value)] += 1
		end
	else
		buffer.copy(q, 0, board.q)
		-- The previous board was validated atomically. Only changed cells need recounting.
		counts = table.clone(board.counts)
		local seen: { [number]: boolean } = {}
		for offset = 17, length - 1, 3 do
			local index, value = buffer.readu16(payload, offset), buffer.readi8(payload, offset + 2)
			if index > 1023 or value < -3 or value > 3 or seen[index] then
				return nil, 0, "cell"
			end
			seen[index] = true
			counts[Math.owner(buffer.readi8(q, index))] -= 1
			counts[Math.owner(value)] += 1
			buffer.writei8(q, index, value)
		end
	end
	if counts[1] ~= buffer.readu16(payload, 13) or counts[2] ~= buffer.readu16(payload, 15) then
		return nil, 0, "counts"
	end
	return { q = q, counts = counts, version = version }, tick, nil
end
function Protocol.motion(balls: { Types.Ball }, tick: number): buffer
	local payload = buffer.create(5 + #balls * 74)
	buffer.writeu32(payload, 0, tick)
	buffer.writeu8(payload, 4, #balls)
	for i, b in balls do
		local o = 5 + (i - 1) * 74
		buffer.writeu8(payload, o, b.id)
		buffer.writef32(payload, o + 1, b.x)
		buffer.writef32(payload, o + 5, b.z)
		buffer.writef32(payload, o + 9, b.vx)
		buffer.writef32(payload, o + 13, b.vz)
		buffer.writef32(payload, o + 17, b.brush)
		buffer.writeu32(payload, o + 21, b.nextAbilityTick)
		buffer.writeu32(payload, o + 25, b.effectEndTick)
		local w = b.weapon or Weapon.new(b.x, b.z, 0)
		buffer.writef32(payload, o + 29, w.hp)
		buffer.writef32(payload, o + 33, w.angle)
		buffer.writef32(payload, o + 37, w.omega)
		buffer.writeu32(payload, o + 41, w.poweredUntil)
		buffer.writeu32(payload, o + 45, w.slowUntil)
		buffer.writeu32(payload, o + 49, w.guardReadyTick)
		buffer.writei32(payload, o + 53, w.castTick)
		buffer.writef32(payload, o + 57, w.castX)
		buffer.writef32(payload, o + 61, w.castZ)
		buffer.writef32(payload, o + 65, w.castAngle)
		buffer.writeu8(payload, o + 69, if w.castCancelled then 1 else 0)
		buffer.writef32(payload, o + 70, w.spin)
	end
	assert(buffer.len(payload) < 900, "Motion payload budget")
	return payload
end
export type Motion = {
	weapon: Types.WeaponState,
	id: number,
	x: number,
	z: number,
	vx: number,
	vz: number,
	brush: number,
	nextAbilityTick: number,
	effectEndTick: number,
}
function Protocol.decodeMotion(payload: buffer): ({ Motion }?, number)
	if buffer.len(payload) < 5 then
		return nil, 0
	end
	local count = buffer.readu8(payload, 4)
	if count > 4 or buffer.len(payload) ~= 5 + 74 * count then
		return nil, 0
	end
	local balls: { Motion } = {}
	for i = 1, count do
		local o = 5 + (i - 1) * 74
		local b = {
			id = buffer.readu8(payload, o),
			x = buffer.readf32(payload, o + 1),
			z = buffer.readf32(payload, o + 5),
			vx = buffer.readf32(payload, o + 9),
			vz = buffer.readf32(payload, o + 13),
			brush = buffer.readf32(payload, o + 17),
			nextAbilityTick = buffer.readu32(payload, o + 21),
			effectEndTick = buffer.readu32(payload, o + 25),
			weapon = {
				spin = buffer.readf32(payload, o + 70),
				hp = buffer.readf32(payload, o + 29),
				angle = buffer.readf32(payload, o + 33),
				omega = buffer.readf32(payload, o + 37),
				poweredUntil = buffer.readu32(payload, o + 41),
				slowUntil = buffer.readu32(payload, o + 45),
				guardReadyTick = buffer.readu32(payload, o + 49),
				castTick = buffer.readi32(payload, o + 53),
				castX = buffer.readf32(payload, o + 57),
				castZ = buffer.readf32(payload, o + 61),
				castAngle = buffer.readf32(payload, o + 65),
				castCancelled = buffer.readu8(payload, o + 69) == 1,
			},
		}
		if
			b.id ~= i
			or not Protocol.finite(b.x)
			or not Protocol.finite(b.z)
			or not Protocol.finite(b.vx)
			or not Protocol.finite(b.vz)
			or not Protocol.finite(b.brush)
			or math.abs(b.x) > 31
			or math.abs(b.z) > 31
			or math.abs(b.vx) > 30.01
			or math.abs(b.vz) > 30.01
			or b.brush < 0
			or b.brush > 8
		then
			return nil, 0
		end
		local w = b.weapon
		if
			not Protocol.finite(w.hp)
			or not Protocol.finite(w.spin)
			or w.spin < 0
			or w.spin > 100000
			or w.hp < 0
			or w.hp > 100
			or not Protocol.finite(w.angle)
			or math.abs(w.angle) > 100000
			or not Protocol.finite(w.omega)
			or math.abs(w.omega) > 20
			or not Protocol.finite(w.castX)
			or math.abs(w.castX) > 45
			or not Protocol.finite(w.castZ)
			or math.abs(w.castZ) > 45
			or not Protocol.finite(w.castAngle)
			or math.abs(w.castAngle) > 100000
			or buffer.readu8(payload, o + 69) > 1
		then
			return nil, 0
		end
		table.insert(balls, b)
	end
	return balls, buffer.readu32(payload, 0)
end
return table.freeze(Protocol)
