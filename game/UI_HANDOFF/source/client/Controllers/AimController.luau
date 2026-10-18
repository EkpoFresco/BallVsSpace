--!strict
local Layout = require(script.Parent.ReferenceLayout)
local Aim = {}
function Aim.angle(viewport: Vector2, screen: Vector2, x: number, z: number): number?
	local p = Layout.screenToCanvas(screen, viewport) - Layout.ball(x, z)
	if p.Magnitude < 4 then
		return nil
	end
	return math.deg(math.atan2(p.Y, p.X)) % 360
end
function Aim.draw(lines: { Frame }, x: number, z: number, angle: number)
	local center = Layout.ball(x, z)
	local direction = Vector2.new(math.cos(math.rad(angle)), math.sin(math.rad(angle)))
	local length = 160
	for _, axis in { 1, 2 } do
		local component = if axis == 1 then direction.X else direction.Y
		local position = if axis == 1 then center.X else center.Y
		local low = if axis == 1 then 185 else 85
		local high = if axis == 1 then 617 else 517
		if math.abs(component) > 0.001 then
			length = math.min(length, ((if component > 0 then high else low) - position) / component - 8)
		end
	end
	for j = 1, 4 do
		local distance = 42 + (j - 1) * 37
		local p = center + direction * distance
		lines[j].Position = UDim2.fromOffset(p.X, p.Y)
		lines[j].Size = UDim2.fromOffset(29, 18)
		lines[j].Rotation = angle
		lines[j].Visible = distance < length - 15
	end
	local tip = center + direction * length
	local head = tip - direction * 15
	lines[5].Size = UDim2.fromOffset(30, 54)
	lines[5].Position = UDim2.fromOffset(head.X, head.Y)
	lines[5].Rotation = angle
	lines[5].Visible = length > 52
	lines[6].Visible = false
	lines[7].Visible = false
end
return table.freeze(Aim)
