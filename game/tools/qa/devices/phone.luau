local svc=game:GetService("StudioDeviceSimulatorService")
local chosen
for _,id in svc:GetDeviceListAsync() do
 if svc:GetDeviceInfoAsync(id).Name=="iPhone 17 Pro" then chosen=id;break end
end
assert(chosen,"Expected observed iPhone 17 Pro device")
local ok,err=pcall(function()
 svc:SetDeviceAsync(chosen)
 svc:SetOrientationAsync(Enum.ScreenOrientation.LandscapeLeft)
end)
assert(ok,err)
task.wait(0.2)
return {device=chosen,orientation=tostring(svc:GetOrientationAsync()),viewport=tostring(workspace.CurrentCamera.ViewportSize),scaling=tostring(svc:GetScalingModeAsync())}
