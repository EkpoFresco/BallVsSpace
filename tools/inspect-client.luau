local w=game:GetService("Workspace")
local p=game:GetService("Players").LocalPlayer
local g=p.PlayerGui:FindFirstChild("BallVsSpace")
local c=w.CurrentCamera
local t=w:FindFirstChild("BVSTerritory")
return {camera=tostring(c.CFrame),size=tostring(c.ViewportSize),cameraType=tostring(c.CameraType),cell=t and tostring(t:GetChildren()[500].Position),phase=g and g:GetAttribute("Phase"),tick=g and g:GetAttribute("Tick"),board=g and g:GetAttribute("BoardHash"),status=g and g.Status.Text,serverPhase=w:GetAttribute("BVSPhase"),serverTick=w:GetAttribute("BVSTick"),serverBoard=w:GetAttribute("BVSBoardHash")}
