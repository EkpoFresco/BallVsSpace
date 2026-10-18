--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local Geometry = require(Shared.Geometry2D)
local Math = require(Shared.TerritoryMath)
local Types = require(Shared.Types)
local Territory = {}
function Territory.new(): Types.Board
	return { q = buffer.create(1024), counts = { [0] = 1024, [1] = 0, [2] = 0 }, version = 0 }
end
local function stamp(mask: buffer, shape: Types.Shape)
	local x0, x1, z0, z1 = Geometry.cellBounds(shape.ax, shape.az, shape.bx, shape.bz, shape.radius)
	for z = z0, z1 do
		for x = x0, x1 do
			if
				Geometry.distanceSquaredToSegment(
					-31 + 2 * x,
					-31 + 2 * z,
					shape.ax,
					shape.az,
					shape.bx,
					shape.bz
				) <= shape.radius ^ 2 + 1e-9
			then
				local index = z * 32 + x
				buffer.writeu8(mask, index, math.max(buffer.readu8(mask, index), shape.strength))
			end
		end
	end
end
function Territory.seed(board: Types.Board, balls: { Types.Ball })
	for _, ball in balls do
		for i = 0, 1023 do
			local x, z = -31 + 2 * (i % 32), -31 + 2 * (i // 32)
			if (x - ball.x) ^ 2 + (z - ball.z) ^ 2 <= 16 then
				buffer.writei8(board.q, i, if ball.team == 1 then 3 else -3)
			end
		end
	end
	board.counts = Math.count(board.q)
	board.version += 1
end
function Territory.resolve(
	board: Types.Board,
	paths: { Types.Segment },
	effects: { Types.Shape }
): { Types.Change }
	local masks = { buffer.create(1024), buffer.create(1024) }
	local drain = buffer.create(1024)
	for _, path in paths do
		stamp(masks[path.team], {
			ax = path.ax,
			az = path.az,
			bx = path.bx,
			bz = path.bz,
			radius = path.radius,
			team = path.team,
			strength = 1,
		})
	end
	for _, shape in effects do
		stamp(if shape.drain then drain else masks[shape.team], shape)
	end
	local changes: { Types.Change } = {}
	for i = 0, 1023 do
		local old = buffer.readi8(board.q, i)
		local q = Math.resolve(
			old,
			buffer.readu8(masks[1], i),
			buffer.readu8(masks[2], i),
			buffer.readu8(drain, i) > 0
		)
		if old ~= q then
			board.counts[Math.owner(old)] -= 1
			board.counts[Math.owner(q)] += 1
			buffer.writei8(board.q, i, q)
			table.insert(changes, { index = i, q = q })
		end
	end
	if #changes > 0 then
		board.version += 1
	end
	-- Slice deliberately audits every update, including unchanged ownership.
	local audit = Math.count(board.q)
	assert(
		audit[0] == board.counts[0] and audit[1] == board.counts[1] and audit[2] == board.counts[2],
		"Territory count mismatch"
	)
	return changes
end
return table.freeze(Territory)
