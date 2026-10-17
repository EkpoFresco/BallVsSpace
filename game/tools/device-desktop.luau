local svc=game:GetService("StudioDeviceSimulatorService")
local devices=svc:GetDeviceListAsync()
local selected
for _,id in devices do
 local info=svc:GetDeviceInfoAsync(id)
 if info.Name=="Average Laptop" then selected=id;break end
end
if not selected then selected=svc:CreateDeviceAsync({Name="BVS Desktop QA",Width=1920,Height=1080,PixelDensity=96}) end
svc:SetDeviceAsync(selected)
svc:SetResolutionAsync(1920,1080)
svc:SetScalingModeAsync(Enum.DeviceSimulatorScalingMode.FitToWindow)
task.wait(0.2)
return {device=selected,resolution=tostring(svc:GetResolutionAsync()),viewport=tostring(workspace.CurrentCamera.ViewportSize)}
