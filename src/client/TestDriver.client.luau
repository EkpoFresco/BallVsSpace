--!strict
-- Explicit Studio-only automation. Two real clients submit ordinary remote commands.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
if not RunService:IsStudio() then
	return
end
local ViewTypes = require(ReplicatedStorage.Shared.ViewTypes)
local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
assert(remotes, "Missing test remotes")
local command = remotes:WaitForChild("ClientCommand", 10) :: RemoteEvent
local states = remotes:WaitForChild("MatchState", 10) :: RemoteEvent
local candidate = remotes:WaitForChild("TestTelemetry", 5)
if not candidate or not candidate:IsA("RemoteEvent") then
	return
end
local telemetry = candidate
local nextId = 100000
local seen: { [string]: boolean } = {}
local function send(kind: string, v: ViewTypes.State?, kit: string?, angle: number?)
	nextId += 1
	command:FireServer({
		id = nextId,
		kind = kind,
		matchId = if v then v.id else "",
		roundId = if v then v.roundId else 0,
		generation = if v then v.generation else 0,
		kitId = kit,
		appearance = if kind == "Select"
			then (if kit == "Anchor" then "Axe" elseif v and v.roundNumber == 2 then "Cell" else "Acid")
			else nil,
		angle = angle,
	})
end
states.OnClientEvent:Connect(function(v: ViewTypes.State)
	local key = (v.id or "lobby") .. ":" .. tostring(v.roundId) .. ":" .. v.phase
	if v.phase == "Lobby" then
		task.delay(0.5, function()
			send("Queue", nil)
		end)
		return
	end
	if seen[key] then
		return
	end
	seen[key] = true
	if v.phase == "Draft" then
		local kit = if (v.roundNumber + Players.LocalPlayer.UserId) % 2 == 0 then "Drift" else "Anchor"
		task.delay(0.3, function()
			send("Select", v, kit)
			task.wait(0.25)
			send("Commit", v)
		end)
	elseif v.phase == "Aim" then
		local angle = (37 * v.roundNumber + Players.LocalPlayer.UserId * 73) % 360
		task.delay(0.3, function()
			send("Aim", v, nil, angle)
			task.wait(0.25)
			send("AimLock", v)
		end)
	elseif v.phase == "RoundResult" or v.phase == "MatchResult" then
		task.delay(0.5, function()
			local gui = Players.LocalPlayer.PlayerGui:FindFirstChild("BallVsSpace")
			if gui then
				local display = Players.LocalPlayer.PlayerGui:FindFirstChild("BVSBallLabels")
				local canvas = if display then display:FindFirstChild("ReferenceCanvas") else nil
				local visualPass = true
				for i, seat in v.seats do
					local ball = if canvas then canvas:FindFirstChild("Ball" .. i) else nil
					local viewport = if ball then ball:FindFirstChild("Model") else nil
					local world = if viewport then viewport:FindFirstChildOfClass("WorldModel") else nil
					local model = if world then world:FindFirstChildOfClass("Model") else nil
					if not model or model.Name ~= seat.appearance then
						visualPass = false
					end
				end
				telemetry:FireServer({
					visualPass = visualPass,
					matchId = v.id,
					roundId = v.roundId,
					phase = v.phase,
					clientHash = gui:GetAttribute("BoardHash"),
					clientTick = gui:GetAttribute("Tick"),
					serverHash = Workspace:GetAttribute("BVSBoardHash"),
					serverTick = Workspace:GetAttribute("BVSTick"),
				})
			end
			if v.phase == "MatchResult" then
				send("Rematch", v)
			end
		end)
	end
end)
task.delay(2, function()
	send("Ready", nil)
	task.wait(0.3)
	send("Queue", nil)
end)
