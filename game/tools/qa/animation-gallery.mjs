import {writeFileSync} from 'node:fs';
import {createQa} from '../studio/client.mjs';
import {outputFile,luauString} from '../lib/project.mjs';
const studio=process.argv[2],prefix=process.argv[3]??'polish-gallery';
const rpc=createQa(studio,prefix);
const source=`
local p=game.Players.LocalPlayer;local c=p.PlayerScripts.Client.Controllers
local Ui=require(c.ReferenceUi);local Art=require(c.WeaponArt)
local Weapon=require(game.ReplicatedStorage.Shared.WeaponGeometry);local Heroes=require(game.ReplicatedStorage.Shared.HeroDefinitions)
local gui=script.Parent;local cards={};local hidden={}
for _,g in p.PlayerGui:GetChildren() do if g:IsA('ScreenGui') and g~=gui then hidden[g]=g.Enabled;g.Enabled=false end end
local background=Ui.frame(gui,'Background',0,0,1,1,Ui.actionColors.ink);background.Size=UDim2.fromScale(1,1)
local title=Ui.text(background,'Title','WEAPONS IN MOTION',0,0,1,1,24,true);title.Position=UDim2.fromScale(.02,.015);title.Size=UDim2.fromScale(.96,.06)
for i,id in {'Iria','Mira','Ravi','Kesh','Bram','Pax'} do
 local card=Ui.frame(background,id,0,0,1,1,Ui.actionColors.card);card.Position=UDim2.fromScale(.02+((i-1)%3)*.326,.1+math.floor((i-1)/3)*.445);card.Size=UDim2.fromScale(.306,.425)
 local field=Ui.frame(card,'Field',0,0,1,1,Ui.actionColors.card);field.BackgroundTransparency=1;field.Position=UDim2.fromScale(.5,.42);field.AnchorPoint=Vector2.new(.5,.5);field.Size=UDim2.fromScale(.9,.78)
 local aspect=Instance.new('UIAspectRatioConstraint');aspect.AspectType=Enum.AspectType.FitWithinMaxSize;aspect.Parent=field
 local assembly=Art.new(field,'Weapon');local body=Art.image(field,'Body','Body');body.ImageColor3=Heroes.heroes[id].color;body.Position=UDim2.fromScale(.5,.5);body.Size=UDim2.fromScale(.2,.2);body.ZIndex=4
 local glint=Art.image(field,'Glint','Glint');glint.Position=body.Position;glint.Size=body.Size;glint.ZIndex=5;glint.ImageTransparency=.35
 local label=Ui.text(card,'Name',id:upper(),0,0,1,1,18,true);label.Position=UDim2.fromScale(.02,.8);label.Size=UDim2.fromScale(.96,.09)
 local description=Ui.text(card,'Weapon',Heroes.heroes[id].weapon,0,0,1,1,12);description.Position=UDim2.fromScale(.02,.9);description.Size=UDim2.fromScale(.96,.08)
 table.insert(cards,{id=id,assembly=assembly,w=Weapon.new(0,0,0)})
end
local tick=0
local connection=game:GetService('RunService').RenderStepped:Connect(function(dt)
 tick+=dt*60
 for _,v in cards do
  local w=v.w;w.omega=Weapon.angularSpeed(v.id,w,tick);w.angle+=w.omega*dt;w.spin+=math.abs(w.omega)*dt
  if math.floor(tick/240)>math.floor((tick-dt*60)/240) or w.castTick<0 then w.castTick=tick;w.castAngle=w.angle;w.castX=0;w.castZ=0 end
  Art.draw(v.assembly,v.id,0,0,w.angle,Weapon.sample(v.id,0,0,1,w,tick),1/30,.5,.5,false)
 end
 gui:SetAttribute('Frames',(gui:GetAttribute('Frames') or 0)+1)
end)
gui.Destroying:Connect(function() connection:Disconnect();for g,enabled in hidden do if g.Parent then g.Enabled=enabled end end end)
`;
rpc('execute_luau',{datamodel_type:'Client',code:`local p=game.Players.LocalPlayer;local s=game:GetService('StudioDeviceSimulatorService');s:SetDeviceAsync('average_laptop');s:SetResolutionAsync(1280,720);local gui=Instance.new('ScreenGui');gui.Name='QAAnimationGallery';gui.IgnoreGuiInset=true;gui.DisplayOrder=100;gui.Parent=p.PlayerGui;local runner=Instance.new('LocalScript');runner.Source=${luauString(source)};runner.Parent=gui;task.wait(.5);return true`},'install');
try{
 for(let n=1;n<=3;n++){
  rpc('execute_luau',{datamodel_type:'Client',code:'task.wait(.7);return game.Players.LocalPlayer.PlayerGui.QAAnimationGallery:GetAttribute("Frames")'},'frames-'+n);
  rpc('screen_capture',{capture_id:prefix+'-'+n},'motion-'+n);
 }
}finally{
 rpc('execute_luau',{datamodel_type:'Client',code:"local g=game.Players.LocalPlayer.PlayerGui:FindFirstChild('QAAnimationGallery');if g then g:Destroy() end;return true"},'cleanup');
}
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({heroes:['Iria','Mira','Ravi','Kesh','Bram','Pax'],captures:3,scope:'Native real-time sprite animation gallery, separate from authoritative combat tests.'},null,2));
