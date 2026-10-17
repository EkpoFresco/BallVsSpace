--!strict
local Geometry = {}
function Geometry.distanceSquaredToSegment(
	px: number,
	pz: number,
	ax: number,
	az: number,
	bx: number,
	bz: number
): number
	local dx, dz = bx - ax, bz - az
	local length2 = dx * dx + dz * dz
	local t = if length2 > 1e-16 then math.clamp(((px - ax) * dx + (pz - az) * dz) / length2, 0, 1) else 0
	return (px - ax - t * dx) ^ 2 + (pz - az - t * dz) ^ 2
end
function Geometry.cellBounds(
	ax: number,
	az: number,
	bx: number,
	bz: number,
	radius: number
): (number, number, number, number)
	return math.max(0, math.ceil((math.min(ax, bx) - radius + 31) / 2)),
		math.min(31, math.floor((math.max(ax, bx) + radius + 31) / 2)),
		math.max(0, math.ceil((math.min(az, bz) - radius + 31) / 2)),
		math.min(31, math.floor((math.max(az, bz) + radius + 31) / 2))
end
function Geometry.sweepCircleWall(p: number, v: number, bound: number, limit: number): number?
	if math.abs(v) < 1e-12 then
		return nil
	end
	local t = ((if v > 0 then bound else -bound) - p) / v
	if t >= -1e-9 and t <= limit + 1e-9 then
		return math.max(0, t)
	end
	return nil
end
function Geometry.sweepCircleCircle(
	dx: number,
	dz: number,
	vx: number,
	vz: number,
	radius: number,
	limit: number
): number?
	local approach = dx * vx + dz * vz
	if approach >= -1e-10 then
		return nil
	end
	local c = dx * dx + dz * dz - radius * radius
	if c <= 1e-9 then
		return 0
	end
	local a = vx * vx + vz * vz
	local discriminant = approach * approach - a * c
	if discriminant < 0 or a < 1e-12 then
		return nil
	end
	local t = (-approach - math.sqrt(discriminant)) / a
	if t >= 0 and t <= limit + 1e-9 then
		return math.min(t, limit)
	end
	return nil
end
return table.freeze(Geometry)
