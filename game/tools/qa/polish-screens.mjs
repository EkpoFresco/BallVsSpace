// Isolated native utility panels; use live-flow/menu drivers for actual input.
import {readFileSync,writeFileSync} from 'node:fs';
import {createQa} from '../studio/client.mjs';
import {gameRoot,outputFile,luauString} from '../lib/project.mjs';
const [studio,prefix='polish-screens']=process.argv.slice(2);
if(!studio)throw Error('Explicit Studio ID required');
const rpc=createQa(studio,prefix);
const run=(code,label)=>rpc('execute_luau',{datamodel_type:'Client',code},label);
const source=readFileSync(gameRoot+'/tools/qa/fixtures/scale-review.luau','utf8');
const rows=[];
try{
 run(`local p=game.Players.LocalPlayer.PlayerScripts;local old=p:FindFirstChild('QAScaleReview');if old then require(old).destroy();old:Destroy() end;local m=Instance.new('ModuleScript');m.Name='QAScaleReview';m.Source=${luauString(source)};m.Parent=p;require(m);return true`,'install');
 for(const [size,width,height] of [['short',568,320],['desktop',1280,720]]){
  run(`local s=game:GetService('StudioDeviceSimulatorService');s:SetDeviceAsync('average_laptop');s:SetResolutionAsync(${width},${height});task.wait(.3);return true`,size);
  for(const state of ['Rewards','How to play','Settings','Inventory:Explosions']){
   const label=size+'-'+state.replaceAll(' ','-').replaceAll(':','-');
   const row=run(`return require(game.Players.LocalPlayer.PlayerScripts.QAScaleReview).inspect(${luauString(state)})`,'inspect-'+label);
   if(Object.values(row.issues??{}).length)throw Error(JSON.stringify(row));
   rows.push({size,...row});
   rpc('screen_capture',{capture_id:prefix+'-'+label},label);
  }
 }
 // Studio lazily initializes ImageLabels in hidden pages, even for a cached atlas.
 const icons=run(`local a=require(game.Players.LocalPlayer.PlayerScripts.Client.Controllers.Artwork);local count=0;for _,n in game.Players.LocalPlayer.PlayerGui.QAScaleReview:GetDescendants() do if n:IsA('ImageLabel') and n.Image==a.iconAsset then local shown=true;local p=n;while p and not p:IsA('ScreenGui') do if p:IsA('GuiObject') and not p.Visible then shown=false end;p=p.Parent end;if shown then assert(n.IsLoaded,'Visible UI icon did not load: '..n:GetFullName());count+=1 end end end;assert(count>0);return {loadedVisibleImages=count,asset=a.iconAsset}`,'icons');
 writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({scope:'Isolated native panels, emulated sizes; not physical device input.',rows,icons},null,2));
}finally{
 run(`local m=game.Players.LocalPlayer.PlayerScripts:FindFirstChild('QAScaleReview');if m then require(m).destroy();m:Destroy() end;local s=game:GetService('StudioDeviceSimulatorService');s:SetDeviceAsync('average_laptop');s:SetResolutionAsync(1280,720);return true`,'cleanup');
}
