--!strict
local CameraController = {}
function CameraController.fit(camera: Camera)
	local size = camera.ViewportSize
	if size.X < 1 or size.Y < 1 then
		return
	end
	local availableY = math.max(180, size.Y - 92)
	local availableX = math.max(180, size.X - (if size.X >= 700 then 260 else 28))
	local tangent = math.tan(math.rad(35 / 2))
	local courtPixels = math.min(availableX, availableY)
	local distance = 70 * size.Y / courtPixels / (2 * tangent)
	camera.CameraType = Enum.CameraType.Scriptable
	camera.FieldOfView = 35
	local target = Vector3.new(0, 0, -22 * 70 / courtPixels)
	camera.Focus = CFrame.new(target)
	camera.CFrame = CFrame.lookAt(target + Vector3.new(0, distance, 0), target, Vector3.new(0, 0, -1))
end
return table.freeze(CameraController)
