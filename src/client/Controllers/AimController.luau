--!strict
local Geometry = require(game:GetService("ReplicatedStorage").Shared.Geometry2D)
local BallRenderer = require(script.Parent.BallRenderer)
local Aim = {}
function Aim.angle(camera: Camera, screen: Vector2, x: number, z: number): number?
	local ray = camera:ScreenPointToRay(screen.X, screen.Y)
	if math.abs(ray.Direction.Y) < 1e-8 then
		return nil
	end
	local distance = -ray.Origin.Y / ray.Direction.Y
	if distance <= 0 then
		return nil
	end
	local p = ray.Origin + ray.Direction * distance
	if (Vector2.new(p.X - x, p.Z - z)).Magnitude < 0.3 then
		return nil
	end
	return math.deg(math.atan2(p.Z - z, p.X - x)) % 360
end
function Aim.draw(lines: { Part }, x: number, z: number, angle: number)
	local dx, dz = math.cos(math.rad(angle)), math.sin(math.rad(angle))
	local tx = Geometry.sweepCircleWall(x, dx, 30.5, 200) or 200
	local tz = Geometry.sweepCircleWall(z, dz, 30.5, 200) or 200
	local distance = math.min(tx, tz)
	local bx, bz = x + dx * distance, z + dz * distance
	BallRenderer.line(lines[1], Vector3.new(x, 0.3, z), Vector3.new(bx, 0.3, bz), 0.2)
	if tx <= tz + 1e-8 then
		dx = -dx
	end
	if tz <= tx + 1e-8 then
		dz = -dz
	end
	BallRenderer.line(lines[2], Vector3.new(bx, 0.3, bz), Vector3.new(bx + dx * 10, 0.3, bz + dz * 10), 0.12)
	lines[1].Transparency = 0.1
	lines[2].Transparency = 0.45
end
return table.freeze(Aim)
