local p=game.Players.LocalPlayer
local c=p.PlayerScripts.Client.Controllers
local Controller=require(c.MatchController)
local Renderer=require(c.BallRenderer)
local Weapon=require(game.ReplicatedStorage.Shared.WeaponGeometry)
local Protocol=require(game.ReplicatedStorage.Shared.Protocol)
local Heroes=require(game.ReplicatedStorage.Shared.HeroDefinitions)
local Artwork=require(c.Artwork)
game:GetService('ContentProvider'):PreloadAsync({Artwork.iconAsset,Artwork.studAsset,require(c.WeaponArt).asset})
local state=Controller.new()
local function packet(tick)
 local w=Weapon.new(0,0,tick*.05);w.castTick=1;w.omega=3;w.spin=tick*.05
 return Protocol.motion({{id=1,x=0,z=0,vx=0,vz=0,brush=0,nextAbilityTick=240,effectEndTick=0,weapon=w}},tick)
end
Controller.receive(state,packet(0));Controller.receive(state,packet(6))
state.samples[2].received=100
local a,at=Controller.positions(state,100.05)
local b,bt=Controller.positions(state,100.05+1/120)
assert(math.abs(at-3)<.0001 and math.abs(bt-at-.5)<.0001,'Pose clock is not fractional')
assert(b[1].weapon.angle>a[1].weapon.angle,'Spin paused between territory snapshots')
local frozen,ft=Controller.positions(state,120)
local frozenAgain,ft2=Controller.positions(state,130)
assert(ft==12 and ft2==ft and frozenAgain[1].weapon.angle==frozen[1].weapon.angle,'Packet-gap extrapolation is unbounded')
local original=state.samples[1].balls[1].weapon.angle
local blended=Controller.interpolate(state.samples[1].balls,state.samples[2].balls,.5)
blended[1].weapon.angle=99
assert(state.samples[1].balls[1].weapon.angle==original,'Interpolation mutates history')
local render=Renderer.new();render.gui.Name='QAAnimationPolish'
local view={id='animation-test',roundId=1,phase='Battle',tick=3,seats={{team=1,x=0,z=0,kitId='Ravi'}}}
local ok,result=pcall(function()
 Renderer.render(render,a,view,false,at)
 local edge=render.balls[1].edges[1].edge
 local before=edge.Position.X.Scale
 Renderer.render(render,b,view,false,bt)
 assert(edge.Position.X.Scale~=before,'Projectile still samples the stepped territory clock')
 local visual=render.balls[1]
 b[1].weapon.hp=86;Renderer.render(render,b,view,false,bt)
 assert(visual.feedback.Visible and visual.feedback.Text=='-14','Missing damage feedback')
 local initialFeedback=visual.feedbackAt
 Renderer.render(render,b,view,false,bt)
 assert(visual.feedbackAt==initialFeedback,'An unchanged HP value retriggers a hit')
 b[1].weapon.guardReadyTick=125;Renderer.render(render,b,view,false,bt)
 assert(visual.feedback.Text=='BLOCK','Zero-damage guard feedback missing')
 b[1].weapon.hp=91;Renderer.render(render,b,view,true,bt)
 assert(visual.feedback.Text=='+5' and visual.hitRing.Transparency==1 and visual.feedback.Position.Y.Offset==-24,'Reduced motion or healing feedback failed')
 view.roundId=2;b[1].weapon.hp=100;Renderer.render(render,b,view,false,0)
 assert(not visual.feedback.Visible,'Round reset appears as a heal')
 -- Exercise every kit over two continuous seconds, retaining the shared geometry.
 local rendered=0
 for _,id in Heroes.ids do
  view.seats[1].kitId=id;view.roundId+=1
  local w=Weapon.new(0,0,0);w.castTick=1;w.poweredUntil=90
  local pose={id=1,x=0,z=0,vx=0,vz=0,brush=0,nextAbilityTick=240,effectEndTick=0,weapon=w}
  for frame=1,120 do
   local tick=frame+.5;w.omega=Weapon.angularSpeed(id,w,tick);w.angle+=w.omega/60;w.spin+=math.abs(w.omega)/60
   Renderer.render(render,{pose},view,frame%2==0,tick)
   for _,stroke in visual.edges do
    if stroke.edge.Visible then assert(stroke.edge.Size.X.Scale>0 and stroke.edge.Size.Y.Scale>0,'Degenerate active sprite') end
   end
   rendered+=1
  end
  task.wait()
 end
 local iria=Weapon.new(0,0,0);assert(Weapon.angularSpeed('Iria',iria,30)>0 and Weapon.angularSpeed('Iria',iria,210)<0,'Iria reversal lost')
 local mako=Weapon.new(0,0,0);assert(Weapon.angularSpeed('Mako',mako,5)<Weapon.angularSpeed('Mako',mako,50),'Mako windup lost')
 return {fractionalPoseClock=true,projectileBetweenSnapshots=true,packetGapBoundTicks=6,historyImmutable=true,damageBlockHealing=true,noRepeatedHit=true,reducedMotion=true,roundReset=true,heroes=30,poses=rendered,reversalAndWindup=true,scope='Real renderer with synthetic timing and weapon states; gameplay is covered separately by logic, roster and full-flow tests.'}
end)
render.gui:Destroy();assert(ok,result);return result
