local p=game:GetService("Players").LocalPlayer
local cameraModule=require(p.PlayerScripts.Client.Controllers.CameraController)
game:GetService("RunService"):BindToRenderStep("BVSCamera",Enum.RenderPriority.Camera.Value+1,function()
 cameraModule.fit(workspace.CurrentCamera)
end)
return "Applied canonical camera scheduling fix to disposable test client"
