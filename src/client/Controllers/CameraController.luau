--!strict
local CameraController = {}
function CameraController.fit(camera: Camera)
	local size = camera.ViewportSize
	if size.X < 1 or size.Y < 1 then
		return
	end
	local availableY = math.max(120, size.Y - 330)
	local availableX = math.max(100, size.X - 32)
	local tangent = math.tan(math.rad(35 / 2))
	local distance =
		math.max(76 * size.Y / availableY / (2 * tangent), 76 * size.Y / availableX / (2 * tangent))
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = 35
	local target = Vector3.new(0, 0, 2.5)
	camera.Focus = CFrame.new(target)
	camera.CFrame = CFrame.lookAt(
		target + Vector3.new(0, distance * math.sin(math.rad(75)), distance * math.cos(math.rad(75))),
		target
	)
end
return table.freeze(CameraController)
