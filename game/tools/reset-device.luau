local svc=game:GetService("StudioDeviceSimulatorService")
pcall(function() svc:SetOrientationAsync(Enum.ScreenOrientation.LandscapeLeft) end)
svc:StopSimulationAsync()
return "Studio reset to default viewport"
