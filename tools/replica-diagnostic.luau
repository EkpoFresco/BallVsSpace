local p=game:GetService("Players").LocalPlayer
local c=workspace.CurrentCamera
local r=workspace:FindFirstChild("BVSCourt")
local g=p.PlayerGui:FindFirstChild("BallVsSpace")
return {character=p.Character and p.Character:GetFullName(),auto=game:GetService("Players").CharacterAutoLoads,camera=tostring(c.CFrame),focus=tostring(c.Focus),type=tostring(c.CameraType),viewport=tostring(c.ViewportSize),root=r and #r:GetChildren(),phase=g and g:GetAttribute("Phase"),lighting=game:GetService("Lighting").Brightness,sky=game:GetService("Lighting"):FindFirstChildOfClass("Sky") and game:GetService("Lighting"):FindFirstChildOfClass("Sky").SkyboxBk}
