local r=game:GetService("RunService")
game:GetService("StudioDeviceSimulatorService"):SetScalingModeAsync(Enum.DeviceSimulatorScalingMode.ActualResolution)
task.wait(1)
local g=game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace
local icons={}
for _,v in g:GetDescendants() do if v:IsA("ViewportFrame") then table.insert(icons,{path=v:GetFullName(),size=tostring(v.AbsoluteSize),camera=v.CurrentCamera and tostring(v.CurrentCamera.CFrame),parts=#v:GetDescendants()}) end end
return {rendering=r:IsRunning(),icons=icons}
