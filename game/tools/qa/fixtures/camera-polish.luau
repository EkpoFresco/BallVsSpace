local p=game.Players.LocalPlayer
local original=p.PlayerScripts.Client.Controllers.CameraController
local clone=original:Clone();clone.Name='QACameraController';clone.Parent=original.Parent
local Controller=require(clone)
local camera=Instance.new('Camera')
local h=p.Character:FindFirstChildOfClass('Humanoid')
local saved={h.WalkSpeed,h.JumpPower,h.JumpHeight}
local ok,result=pcall(function()
 h.WalkSpeed,h.JumpPower,h.JumpHeight=23,67,9.5
 Controller.fit(camera,'Battle')
 assert(h.WalkSpeed==0 and h.JumpPower==0 and h.JumpHeight==0,'Battle leaves a jump mode active')
 Controller.fit(camera,'Lobby')
 assert(camera.CameraSubject==h and camera.CameraType==Enum.CameraType.Custom,'Lobby subject not restored')
 assert(h.WalkSpeed==23 and h.JumpPower==67 and h.JumpHeight==9.5,'Movement settings not restored')
 local replacement=Instance.new('Camera')
 Controller.fit(replacement,'Lobby')
 assert(replacement.CameraSubject==h and replacement.FieldOfView==70,'Replacement camera ignored while in lobby')
 local writes=0
 local connection=replacement:GetPropertyChangedSignal('CFrame'):Connect(function()writes+=1 end)
 for _=1,1000 do Controller.fit(replacement,'Lobby') end
 task.wait();connection:Disconnect();replacement:Destroy()
 assert(writes==0,'Unchanged lobby rewrites camera')
 return {jumpModesFrozen=true,movementRestored=true,replacementCamera=true,unchangedCalls=1000,cameraWrites=0}
end)
h.WalkSpeed,h.JumpPower,h.JumpHeight=saved[1],saved[2],saved[3]
camera:Destroy();clone:Destroy();assert(ok,result);return result
