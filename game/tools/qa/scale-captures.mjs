import {writeFileSync} from 'node:fs';
import {gameRoot,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2];if(!studio)throw Error('Explicit Studio ID required');
process.chdir(gameRoot);const rpc=createQa(studio,'scale-visual');
const run=(code,label)=>rpc('execute_luau',{datamodel_type:'Client',code},label);
const all=['Lobby','Queued','Inventory:Balls','Inventory:Explosions','Inventory:Flyers','Inventory:Fusion','Store','Rewards','Play','How to play','Trade','Emotes','Invite friends','Settings','Draft','Collection','Aim','Countdown','Battle','Overtime','Results','Toast'];
const receipts=[];
for(const [device,id,w,h,frames] of [['phone','iphone_17_pro',0,0,all],['small','average_laptop',568,320,['Lobby','Inventory:Balls','Store','Draft','Collection','Results']],['desktop','average_laptop',1280,900,['Lobby','Inventory:Balls','Draft']]]){
 run(`local s=game:GetService('StudioDeviceSimulatorService');s:SetDeviceAsync(${JSON.stringify(id)});${w?`s:SetResolutionAsync(${w},${h});`:`s:SetOrientationAsync(Enum.ScreenOrientation.LandscapeLeft);`}task.wait(.3);return true`,'device-'+device);
 for(const name of frames){
  const label=device+'-'+name.replaceAll(':','-').replaceAll(' ','-');
  receipts.push(run(`return require(game.Players.LocalPlayer.PlayerScripts.QAScaleReview).inspect(${JSON.stringify(name)})`,'measure-'+label));
  rpc('screen_capture',{capture_id:label},label);
 }
}
writeFileSync(outputFile('scale-visual-result.json'),JSON.stringify({scope:'Isolated native UI states, not a live match',checks:receipts},null,2));
