local svc=game:GetService("StudioDeviceSimulatorService")
svc:SetOrientationAsync(Enum.ScreenOrientation.LandscapeLeft)
task.wait(0.2)
return {orientation=tostring(svc:GetOrientationAsync()),viewport=tostring(workspace.CurrentCamera.ViewportSize)}
