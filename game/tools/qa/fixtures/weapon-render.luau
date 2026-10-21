-- Cross-check actual engine layout against shared hit geometry for every hero.
local player=game.Players.LocalPlayer
local controllers=player.PlayerScripts.Client.Controllers
local Renderer=require(controllers.BallRenderer)
local Layout=require(controllers.ReferenceLayout)
local Heroes=require(game.ReplicatedStorage.Shared.HeroDefinitions)
local Weapon=require(game.ReplicatedStorage.Shared.WeaponGeometry)
local WeaponArt=require(controllers.WeaponArt)
local state=Renderer.new();state.gui.Name="BVSWeaponRenderCheck"
local ok,result=pcall(function()
 game:GetService('ContentProvider'):PreloadAsync({WeaponArt.asset})
 local checked,guards,maxCenterError,maxWidthError=0,0,0,0
 for variant,tick in {60,160,280} do
 for i,id in Heroes.ids do
  local pose=Weapon.new(-9,7,i*.37);pose.omega=Weapon.angularSpeed(id,pose,tick)
  pose.spin=variant*math.pi*2.2;pose.castTick=if variant==3 then 240 else 0
  pose.poweredUntil=if variant==2 then tick+30 else 0
  pose.guardReadyTick=if variant==2 then tick+30 else 0
  local seat={id=1,userId=player.UserId,team=1,kitId=id,appearance=id,x=-9,z=7,weapon=pose}
  local view={phase="Battle",tick=tick,seats={seat}}
  local p={id=1,x=-9,z=7,vx=18,vz=0,brush=0,nextAbilityTick=240,effectEndTick=0,weapon=pose}
  Renderer.render(state,{p},view,true);task.wait()
  local deadline=os.clock()+5
  repeat
   local ready=true
   for _,item in state.balls[1].edges do if item.edge.Visible and not item.edge.IsLoaded then ready=false end end
   if ready then break end
   task.wait(.05)
  until os.clock()>deadline
  for n,edge in Weapon.sample(id,-9,7,1,pose,tick) do
   if edge.kind=='guard' then
    local shield=state.balls[1].assembly.guard
    assert(shield.Visible and shield.IsLoaded and shield:GetAttribute('Sprite')=='Guard',id..' missing shield')
    assert(math.abs(shield.ImageTransparency-(if variant==2 then .65 else 0))<.001,'Shield cooldown cue')
    guards+=1;continue
   end
   local visual=state.balls[1].edges[n].edge
   assert(visual.Visible and visual.IsLoaded and visual.Image==WeaponArt.asset,id..' missing authored weapon')
   assert(visual:GetAttribute('Sprite')==(if edge.kind=='seed' then 'Seed' else id),id..' wrong weapon')
   local expected=state.root.AbsolutePosition+Layout.ball((edge.ax+edge.bx)/2,(edge.az+edge.bz)/2)*state.scale.Scale
   local actual=visual.AbsolutePosition+visual.AbsoluteSize/2
   local error=(expected-actual).Magnitude;maxCenterError=math.max(maxCenterError,error)
   -- Parent and child offsets round independently to device pixels.
   assert(error<1.5,id.." weapon drawn away from hitbox: "..tostring(actual-expected))
   local expectedWidth=edge.radius*2*446/64*state.scale.Scale
   local widthError=math.abs(visual.AbsoluteSize.Y-expectedWidth);maxWidthError=math.max(maxWidthError,widthError)
   assert(widthError<1,id.." weapon width mismatch")
   checked+=1
  end
 end
 end
 return {heroes=30,poses=90,edges=checked,guardSegments=guards,asset=WeaponArt.asset,loadedSprites=true,screenPosition=true,screenWidth=true,maxCenterErrorPixels=maxCenterError,maxWidthErrorPixels=maxWidthError,method="Actual active sprite bounds versus shared capsule geometry at three poses, including projectiles, extensions, power and spent guards. 1.5px center / 1px width tolerance. Silhouettes use capsule collision approximation, not per-pixel collision."}
end)
state.gui:Destroy();assert(ok,result);return result
