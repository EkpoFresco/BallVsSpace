local player = game:GetService("Players").LocalPlayer
local modules = player.PlayerScripts.Client.Controllers
local Controller = require(modules.MatchController)
local Protocol = require(game:GetService("ReplicatedStorage").Shared.Protocol)
local Panels = require(modules.LobbyPanels)
local Art = require(modules.BallArt)
local state = Controller.new()
local function payload(tick, x, vx)
 return Protocol.motion({{id=1,x=x,z=0,vx=vx,vz=0,brush=4,nextAbilityTick=360,effectEndTick=0}},tick)
end
Controller.receive(state,payload(0,-12,0))
Controller.receive(state,payload(3,-11,18))
assert(Controller.positions(state,state.samples[2].received)[1].x==-12,"Startup must hold earliest sample")
Controller.receive(state,payload(3,-11,20))
assert(#state.samples==2 and state.samples[2].balls[1].vx==20,"Same-tick velocity refresh")
Controller.receive(state,payload(2,-20,10))
assert(state.latestTick==3 and state.samples[2].balls[1].x==-11,"Stale motion ignored")
local gui=Instance.new("ScreenGui")
gui.Name="BVSReviewRegression"
gui.Parent=player.PlayerGui
local ok,result=pcall(function()
 local s=Panels.new(gui)
 Panels.layout(s,Vector2.new(800,600),1)
 task.wait()
 local action=s.windows.Store.Offers.ViewLaser
 local original=action.TextSize
 Panels.layout(s,Vector2.new(401,873),0.5)
 task.wait()
 assert(action.ButtonText.TextSize==action.TextSize,"Portrait caption follows button")
 Panels.layout(s,Vector2.new(800,600),1)
 task.wait()
 assert(action.TextSize==original and action.ButtonText.TextSize==original,"Font survives orientation round trip")
 Panels.notify(s,"first")
 task.wait(3.55)
 Panels.notify(s,"second")
 task.wait(0.3)
 assert(s.toast.Visible and s.toast.TextTransparency==0 and s.toast.Text=="second","Older fade must not hide newer notification")
 local preview=Art.viewport(gui,"ReviewPreview","Acid")
 task.wait(1)
 Art.animate(preview,0,0,true)
 local before=#gui:GetDescendants()
 for index=1,100 do
  Panels.open(s,if index%2==0 then "Inventory" else "Store")
  Panels.select(s,if index%2==0 then "Acid" else "Axe")
  Panels.close(s)
  local world=preview:FindFirstChildOfClass("WorldModel")
  world:ClearAllChildren()
  local id=if index%2==0 then "Acid" else "Axe"
  Art.setSkin(preview,id)
  Art.build(world,id)
  Art.animate(preview,0,index,true)
 end
 task.wait(0.3)
 local after=#gui:GetDescendants()
 assert(after<=before,"UI or skin switching leaked Instances")
 return {startupInterpolation=true,sameTickVelocity=true,staleMotion=true,fontRoundTrip=true,toastRace=true,uiCycles=100,descendantsBefore=before,descendantsAfter=after,scope="Isolated module fixture; not 100 character resets or physical-device input"}
end)
gui:Destroy()
assert(ok,result)
return result
