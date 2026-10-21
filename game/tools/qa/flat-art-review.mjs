// Render all thirty native assemblies, then leave the actual game UI clear.
import { writeFileSync } from 'node:fs';
import { createQa } from '../studio/client.mjs';
import { outputFile } from '../lib/project.mjs';
const studio=process.argv[2], prefix=process.argv[3]??'flat-v3-art';
if(!studio) throw Error('Explicit Studio ID required');
const rpc=createQa(studio,prefix), receipts=[];
for(let page=0;page<3;page++){
 const result=rpc('execute_luau',{datamodel_type:'Client',code:`
 local player=game.Players.LocalPlayer;local c=player.PlayerScripts.Client.Controllers
 local Portrait=require(c.HeroPortrait);local WeaponArt=require(c.WeaponArt);local Ui=require(c.ReferenceUi)
 local Heroes=require(game.ReplicatedStorage.Shared.HeroDefinitions)
 local simulator=game:GetService('StudioDeviceSimulatorService');simulator:SetDeviceAsync('average_laptop');simulator:SetResolutionAsync(1280,720)
 local old=player.PlayerGui:FindFirstChild('QAFlatArt');if old then old:Destroy() end
 local gui=Instance.new('ScreenGui');gui.Name='QAFlatArt';gui.DisplayOrder=100;gui.IgnoreGuiInset=true;gui.Parent=player.PlayerGui
 local bg=Instance.new('Frame');bg.Size=UDim2.fromScale(1,1);bg.BackgroundColor3=Ui.actionColors.ink;bg.Parent=gui
 local header=Ui.text(bg,'Heading','FLAT ARMORY / ${page+1} OF 3',24,12,900,45,28,true);header.TextXAlignment=Enum.TextXAlignment.Left
 local ids={};local loaded=0
 for slot=1,10 do
  local id=Heroes.ids[${page*10}+slot];table.insert(ids,id)
  local frame=Instance.new('Frame');frame.BackgroundColor3=Ui.actionColors.card;frame.BorderSizePixel=0;frame.Position=UDim2.fromScale(.02+((slot-1)%5)*.194,.1+math.floor((slot-1)/5)*.44);frame.Size=UDim2.fromScale(.18,.41);frame.Parent=bg
  local preview=Instance.new('Frame');preview.BackgroundTransparency=1;preview.Position=UDim2.fromScale(.04,.02);preview.Size=UDim2.fromScale(.92,.77);preview.Parent=frame;Portrait.draw(preview,id,true)
  local name=Ui.text(frame,'Name',id:upper(),0,0,1,1,17,true);name.Size=UDim2.fromScale(1,.1);name.Position=UDim2.fromScale(0,.8)
  local weapon=Ui.text(frame,'Weapon',Heroes.heroes[id].weapon,0,0,1,1,12);weapon.Size=UDim2.fromScale(1,.09);weapon.Position=UDim2.fromScale(0,.9)
 end
 game:GetService('ContentProvider'):PreloadAsync({WeaponArt.asset})
 local deadline=os.clock()+20
 repeat
  task.wait(.1);local ready=true
  for _,d in gui:GetDescendants() do if d:IsA('ImageLabel') and d.Visible and not d.IsLoaded then ready=false end end
  if ready then break end
 until os.clock()>deadline
 for _,d in gui:GetDescendants() do
  assert(d.Name~='Eye0' and d.Name~='CrownBand','Retired face art survived')
  if d:IsA('ImageLabel') and d.Visible then assert(d.IsLoaded,'Missing sprite '..d.Name);loaded+=1 end
  if d.Name=='Shell' and d:IsA('ImageLabel') then assert(math.abs(d.AbsoluteSize.X-d.AbsoluteSize.Y)<1,'Ball stretched') end
 end
 assert(Ui.actionColors.ink==Color3.fromRGB(16,13,20) and Ui.actionColors.crimson==Color3.fromRGB(184,11,81),'Palette regression')
 assert(Ui.displayFont.Style==Enum.FontStyle.Italic,'Display font regression')
 return {heroes=ids,loadedSprites=loaded,roundBodies=true,paletteRestored=true,displayItalic=true,viewport={gui.AbsoluteSize.X,gui.AbsoluteSize.Y}}
 `},`page-${page+1}`);
 receipts.push(result);
 rpc('screen_capture',{capture_id:`${prefix}-${page+1}`},`sheet-${page+1}`);
}
rpc('execute_luau',{datamodel_type:'Client',code:"game.Players.LocalPlayer.PlayerGui.QAFlatArt:Destroy();return true"},'clear');
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({pages:receipts,heroes:30,physicalDevice:false},null,2));
console.log('Thirty hero assemblies rendered and checked.');
