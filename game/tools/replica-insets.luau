local g=game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace
return {guiSize=tostring(g.AbsoluteSize),guiPosition=tostring(g.AbsolutePosition),rootPosition=tostring(g.ReferenceCanvas.AbsolutePosition),rootSize=tostring(g.ReferenceCanvas.AbsoluteSize),mouse=tostring(game:GetService("UserInputService"):GetMouseLocation()),camera=tostring(workspace.CurrentCamera.ViewportSize)}
