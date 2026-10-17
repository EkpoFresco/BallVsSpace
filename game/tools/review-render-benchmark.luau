local player = game:GetService("Players").LocalPlayer
local Renderer = require(player.PlayerScripts.Client.Controllers.BallRenderer)
local state = Renderer.new()
state.gui.Name = "BVSReviewBenchmark"
local view = { phase = "Battle", seats = { {appearance="Acid",kitId="Drift"}, {appearance="Axe",kitId="Anchor"} } }
local positions = {
 {id=1,x=-12,z=0,vx=18,vz=0,brush=3,nextAbilityTick=360,effectEndTick=0},
 {id=2,x=12,z=0,vx=-13,vz=0,brush=4.5,nextAbilityTick=480,effectEndTick=0},
}
Renderer.render(state, positions, view, false)
task.wait(1)
local ok, result = pcall(function()
 for _, ball in state.balls do assert(ball.viewport.Sprite.IsLoaded, "Benchmark requires loaded atlas") end
 local parts=0
 for _, item in state.gui:GetDescendants() do if item:IsA("BasePart") then parts+=1 end end
 local batches={}
 for batch=1,20 do
  local start=os.clock()
  for step=1,100 do
   positions[1].x=-12+math.sin((batch*100+step)*.01)*6
   positions[2].z=math.cos((batch*100+step)*.01)*8
   Renderer.render(state,positions,view,false)
  end
  batches[batch]=(os.clock()-start)*1000/100
  task.wait()
 end
 table.sort(batches)
 local total=0;for _,time in batches do total+=time end
 local after=0
 for _,item in state.gui:GetDescendants() do if item:IsA("BasePart") then after+=1 end end
 return {iterations=2000,batches=20,meanMs=total/#batches,medianMs=batches[10],p95BatchMs=batches[19],viewportParts=parts,partsAfterRender=after,method="Same two-ball loaded-atlas renderer, 20 batches of 100 calls; not a device FPS claim"}
end)
state.gui:Destroy()
assert(ok,result)
return result
