local svc=game:GetService("StudioDeviceSimulatorService")
local id
for _,candidate in svc:GetDeviceListAsync() do
 if svc:GetDeviceInfoAsync(candidate).Name=="Average Laptop" then id=candidate;break end
end
assert(id)
svc:SetDeviceAsync(id)
svc:SetResolutionAsync(800,600)
svc:SetScalingModeAsync(Enum.DeviceSimulatorScalingMode.FitToWindow)
task.wait(0.2)
return {device=id,viewport=tostring(workspace.CurrentCamera.ViewportSize)}
