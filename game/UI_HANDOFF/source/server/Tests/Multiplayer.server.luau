--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local StudioTestService = game:GetService("StudioTestService")
local Workspace = game:GetService("Workspace")
if not RunService:IsStudio() then
	return
end
local args = StudioTestService:GetTestArgs() or ""
local countText = string.match(args, "^BVS normal%-clock (%d+) matches$")
if args ~= "BVS normal-clock ten matches" and not countText and game:GetAttribute("BVSAutoTest") ~= true then
	return
end
local target = math.clamp(tonumber(countText) or 10, 1, 20)
local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
assert(remotes, "Missing test remotes")
local telemetry = Instance.new("RemoteEvent")
telemetry.Name = "TestTelemetry"
telemetry.Parent = remotes
local reports: { [string]: { [number]: boolean } } = {}
local mismatches = 0
local comparisons = 0
local results = 0
local aborted = 0
local visualFailures = 0
telemetry.OnServerEvent:Connect(function(p, raw: unknown)
	if type(raw) ~= "table" then
		return
	end
	local t = raw :: { [string]: unknown }
	if type(t.matchId) ~= "string" or type(t.roundId) ~= "number" or type(t.phase) ~= "string" then
		return
	end
	local key = t.matchId .. ":" .. t.roundId .. ":" .. t.phase
	local entry: { [number]: boolean } = reports[key] or {}
	reports[key] = entry
	if entry[p.UserId] then
		return
	end
	entry[p.UserId] = true
	comparisons += 1
	if t.visualPass ~= true then
		visualFailures += 1
	end
	local serverHash = Workspace:GetAttribute("BVSBoardHash")
	local serverTick = Workspace:GetAttribute("BVSTick")
	assert(type(serverTick) == "number", "Missing server simulation tick")
	-- An overload abort can freeze between grid updates. The board represents the last sixth tick.
	local pass = t.clientHash == serverHash and t.clientTick == serverTick - serverTick % 6
	if not pass then
		mismatches += 1
	end
	print("BVS CLIENT_COMPARE", p.UserId, key, pass, t.clientHash, serverHash)
	if t.phase == "MatchResult" then
		local count = 0
		for _ in entry do
			count += 1
		end
		if count == 2 then
			if Workspace:GetAttribute("BVSResultReason") == "match_points" then
				results += 1
			else
				aborted += 1
			end
			print("BVS MULTIPLAYER_MATCH", results, "comparisons", comparisons, "mismatches", mismatches)
		end
	end
	Workspace:SetAttribute("BVSTestMatches", results)
	Workspace:SetAttribute("BVSTestComparisons", comparisons)
	Workspace:SetAttribute("BVSTestMismatches", mismatches)
	Workspace:SetAttribute("BVSTestAborted", aborted)
	Workspace:SetAttribute("BVSTestVisualFailures", visualFailures)
	if results >= target then
		task.delay(1, function()
			StudioTestService:EndTest({
				matches = results,
				comparisons = comparisons,
				mismatches = mismatches,
				aborted = aborted,
				visualComparisons = comparisons,
				visualFailures = visualFailures,
				players = #Players:GetPlayers(),
			})
		end)
	end
end)
