local p=game:GetService("Players").LocalPlayer
return {phase=p.PlayerGui.BallVsSpace:GetAttribute("Phase"),viewport=tostring(workspace.CurrentCamera.ViewportSize),cameraType=tostring(workspace.CurrentCamera.CameraType),frames=#p.PlayerGui:GetDescendants()}
