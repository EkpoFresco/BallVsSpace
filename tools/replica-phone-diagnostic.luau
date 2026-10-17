local p=game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace
local b=p.ReferenceCanvas.Controls.Right
local g=game:GetService("GuiService")
return {viewport=tostring(workspace.CurrentCamera.ViewportSize),phase=p:GetAttribute("Phase"),position=tostring(b.AbsolutePosition),size=tostring(b.AbsoluteSize),visible=b.Visible,active=b.Active,inset=tostring(g:GetGuiInset()),orientation=tostring(game:GetService("StudioDeviceSimulatorService"):GetOrientationAsync())}
