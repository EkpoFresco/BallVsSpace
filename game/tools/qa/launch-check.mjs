import {writeFileSync} from 'node:fs';
import {createQa} from '../studio/client.mjs';
import {outputFile} from '../lib/project.mjs';
const studio=process.argv[2],prefix=process.argv[3]??'launch-check';
if(!studio)throw Error('Explicit verified Studio ID required');
const rpc=createQa(studio,prefix);
if(process.argv.includes('--inventory'))rpc('execute_luau',{datamodel_type:'Client',code:`local s=game:GetService('StudioDeviceSimulatorService');s:SetDeviceAsync('average_laptop');s:SetResolutionAsync(1280,720);s:SetScalingModeAsync(Enum.DeviceSimulatorScalingMode.FitToWindow);task.wait(.3);return true`},'desktop');
const result=rpc('execute_luau',{datamodel_type:'Client',code:`
assert(game.PlaceId==0,'Not local');local p=game.Players.LocalPlayer
local g=p.PlayerGui:WaitForChild('BallVsSpace',20);assert(g:GetAttribute('Phase')=='Lobby','Not ready in lobby')
local c=require(game.ReplicatedStorage.Shared.Config);local heroes=require(game.ReplicatedStorage.Shared.HeroDefinitions)
assert(c.BuildVersion=='0.4.2-armory-polish' and #heroes.ids==30)
assert(g.ReferenceCanvas.Lobby.Practice.Visible,'Practice unavailable')
local errors={};for _,m in game:GetService('LogService'):GetLogHistory() do if m.messageType==Enum.MessageType.MessageError then table.insert(errors,m.message) end end
return {phase=g:GetAttribute('Phase'),build=c.BuildVersion,rules=c.RulesVersion,heroes=#heroes.ids,engineVersion=version(),viewport=tostring(g.AbsoluteSize),practiceVisible=true,clientErrors=errors}
`},'ready');
rpc('screen_capture',{capture_id:prefix+'-lobby'},'lobby');
if(process.argv.includes('--inventory')){
 const point=rpc('execute_luau',{datamodel_type:'Client',code:`local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local b=g.ReferenceCanvas.Lobby.Inventory;local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=g.Parent;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy();local p=b.AbsolutePosition+b.AbsoluteSize/2+offset;return {x=p.X,y=p.Y}`},'inventory-point');
 rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',...point},{action:'wait',wait_time_ms:350}]},'inventory-click');
 result.inventory=rpc('execute_luau',{datamodel_type:'Client',code:`local p=game.Players.LocalPlayer;local g=p.PlayerGui.BallVsSpace;local v=g.ReferenceCanvas.Panels.Inventory;assert(v.Visible and v.Close.Visible and v.Content.BallsPage.Visible);local a=require(p.PlayerScripts.Client.Controllers.Artwork);assert(v.Explosions.TabArt.Image==a.iconAsset and v.Explosions.TabArt.IsLoaded);local d=v.Content.BallsPage.Details;assert(d.Description.TextFits and d.Equipped.TextFits);return {visible=true,iconsLoaded=true,stats=d.Equipped.Text,viewport=tostring(g.AbsoluteSize)}`},'inventory-ready');
 rpc('screen_capture',{capture_id:prefix+'-inventory'},'inventory');
}
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({studio,...result},null,2));
console.log('Local build running',result);
