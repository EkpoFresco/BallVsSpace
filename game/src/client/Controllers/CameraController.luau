--!strict
local Players = game:GetService("Players")
local Camera = {}
local lastCamera: Camera? = nil
local lastHumanoid: Humanoid? = nil
local lastLobby: boolean? = nil
local movement: { walk: number, power: number, height: number }? = nil
function Camera.fit(camera: Camera, phase: string)
	local lobby = phase == "Lobby" or phase == "Queued"
	local character = Players.LocalPlayer.Character
	local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
	if camera == lastCamera and humanoid == lastHumanoid and lobby == lastLobby then
		return
	end
	if humanoid ~= lastHumanoid then
		movement = nil
	end
	lastCamera, lastHumanoid, lastLobby = camera, humanoid, lobby
	if lobby then
		if humanoid and character then
			camera.CameraType = Enum.CameraType.Custom
			camera.CameraSubject = humanoid
			camera.FieldOfView = 70
			local p = character:GetPivot().Position
			camera.CFrame = CFrame.lookAt(p + Vector3.new(0, 7, 16), p + Vector3.new(0, 2, 0))
			if movement then
				humanoid.WalkSpeed = movement.walk
				humanoid.JumpPower = movement.power
				humanoid.JumpHeight = movement.height
				movement = nil
			end
		end
	else
		if humanoid then
			movement = movement
				or { walk = humanoid.WalkSpeed, power = humanoid.JumpPower, height = humanoid.JumpHeight }
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.JumpHeight = 0
		end
		camera.CameraType = Enum.CameraType.Scriptable
		camera.FieldOfView = 55
		local target = Vector3.new(0, 26, -100)
		camera.Focus = CFrame.new(target)
		camera.CFrame = CFrame.lookAt(Vector3.new(0, 20, 0), target)
	end
end
return table.freeze(Camera)
