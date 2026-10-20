import {readFileSync,writeFileSync} from 'node:fs';
import {gameRoot,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2],prefix=process.argv[3]||'action-theme-presentation-final';if(!studio)throw Error('Explicit verified Studio ID required');
process.chdir(gameRoot);const rpc=createQa(studio,prefix);
const code=(code,label)=>rpc('execute_luau',{datamodel_type:'Client',code},label);
let phone=false;
const g='game.Players.LocalPlayer.PlayerGui.BallVsSpace';
function click(path,label){const point=code(`local g=${g};local n=g.ReferenceCanvas;for part in string.gmatch(${JSON.stringify(path)},'[^.]+') do n=n:FindFirstChild(part);assert(n) end;local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=g.Parent;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy();local p=n.AbsolutePosition+n.AbsoluteSize/2+offset;return {x=p.X,y=p.Y}`,'point-'+label);rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',...(phone?point:{instance_path:'LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.'+path})},{action:'wait',wait_time_ms:300}]},label);}
const desktop=`local svc=game:GetService('StudioDeviceSimulatorService');for _,id in svc:GetDeviceListAsync() do if svc:GetDeviceInfoAsync(id).Name=='Average Laptop' then svc:SetDeviceAsync(id);break end end;svc:SetResolutionAsync(1280,900);task.wait(.3);return true`;
const checks=[];
function inspect(name,label){checks.push(code(`local g=${g};local p=g.ReferenceCanvas.Panels[${JSON.stringify(name)}];assert(p.Visible);task.wait(.2);local pos=p.AbsolutePosition-g.AbsolutePosition;assert(math.abs(pos.X+p.AbsoluteSize.X/2-g.AbsoluteSize.X/2)<1,'Not centered');assert(pos.X>=-1 and pos.Y>=-1 and pos.X+p.AbsoluteSize.X<=g.AbsoluteSize.X+1 and pos.Y+p.AbsoluteSize.Y<=g.AbsoluteSize.Y+1,'Clipped');assert(p.Close.AbsoluteSize.X>=43.5 and p.Close.AbsoluteSize.Y>=43.5);if p.Name=='Rewards' then assert(p.BackgroundTransparency==0) end;return {panel=p.Name,viewport=tostring(g.AbsoluteSize),size=tostring(p.AbsoluteSize),centered=true,safeArea=true,closeTarget=true}`,'bounds-'+label));rpc('screen_capture',{capture_id:label},label);}
const active=code(`local p=${g}.ReferenceCanvas.Panels;for _,n in p:GetChildren() do if n:IsA('Frame') and n.Visible then return n.Name end end;return ''`,'initial-panel');
if(active)click('Panels.'+active+'.Close','close-initial-panel');
for(const device of ['desktop','landscape-right']){
 phone=device!=='desktop';
 code(device==='desktop'?desktop:readFileSync('tools/qa/devices/phone.luau','utf8').replace('LandscapeLeft','LandscapeRight'),'device-'+device);
 click('Lobby.Inventory','inventory-'+device);inspect('Inventory','inventory-'+device);
 click('Panels.Inventory.SwitchMenu','store-'+device);inspect('Store','store-'+device);
 click('Panels.Store.Close','close-store-'+device);click('Rewards','rewards-'+device);inspect('Rewards','rewards-'+device);click('Panels.Rewards.Close','close-rewards-'+device);
}
phone=false;code(desktop,'restore-desktop');click('Lobby.Inventory','leave-inventory-open');
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({checks,physicalDevice:false,studioLeft:'Play, desktop Inventory open'},null,2));
