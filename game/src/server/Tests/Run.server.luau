--!strict
if not game:GetService("RunService"):IsStudio() or game:GetAttribute("BVSRunTests") ~= true then
	return
end
local Suite = require(script.Parent.Suite)
local ok, result = pcall(Suite.run)
game:SetAttribute("BVSTestsPassed", ok)
if not ok then
	error(result)
end
print("BVS TEST SUITE PASSED", #result)
