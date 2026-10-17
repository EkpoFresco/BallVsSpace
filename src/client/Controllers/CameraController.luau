--!strict
local Players = game:GetService("Players")
local Camera = {}
local wasLobby = false
function Camera.fit(camera: Camera, phase: string)
	local lobby = phase == "Lobby" or phase == "Queued"
	local character = Players.LocalPlayer.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if lobby then
		if not wasLobby and humanoid and character then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid
			camera.FieldOfView = 70
			local p = character:GetPivot().Position
			camera.CFrame = CFrame.lookAt(p + Vector3.new(0, 7, 16), p + Vector3.new(0, 2, 0))
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
			wasLobby = true
		end
	else
		wasLobby = false
		if humanoid then
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
		end
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 55
		local target = Vector3.new(0, 26, -100)
		camera.Focus = CFrame.new(target)
		camera.CFrame = CFrame.lookAt(Vector3.new(0, 20, 0), target)
	end
end
return table.freeze(Camera)
