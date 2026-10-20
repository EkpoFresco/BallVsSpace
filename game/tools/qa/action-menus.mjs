import {readFileSync,writeFileSync} from 'node:fs';
import {gameRoot,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2];if(!studio)throw Error('Explicit verified Studio ID required');
process.chdir(gameRoot);
const rpc=createQa(studio,process.argv[3]||'action-v1');
const code=(code,label)=>rpc('execute_luau',{datamodel_type:'Client',code},label);
const root='game.Players.LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas';
const capture=label=>rpc('screen_capture',{capture_id:label},label);
function reveal(path){code(`local n=${root};for part in string.gmatch(${JSON.stringify(path)},'[^.]+') do n=n:FindFirstChild(part);assert(n,'Missing target') end;local a=n.Parent;while a do if a:IsA('ScrollingFrame') and a.ScrollingEnabled then local delta=n.AbsolutePosition.Y-a.AbsolutePosition.Y;local bottom=delta+n.AbsoluteSize.Y;if delta<0 or bottom>a.AbsoluteSize.Y then a.CanvasPosition=Vector2.new(0,math.clamp(a.CanvasPosition.Y+delta-8,0,math.max(0,a.AbsoluteCanvasSize.Y-a.AbsoluteSize.Y))) end end;a=a.Parent end;task.wait(.1);return true`,'reveal-'+path.split('.').at(-1));}
let phoneInput=false;
function click(path){reveal(path);let target={instance_path:'LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.'+path};{target=code(`local n=${root};for part in string.gmatch(${JSON.stringify(path)},'[^.]+') do n=n:FindFirstChild(part) end;local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=g.Parent;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy();local p=n.AbsolutePosition+n.AbsoluteSize/2+offset;return {x=p.X,y=p.Y}`,'phone-input-point');}rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',...target},{action:'wait',wait_time_ms:250}]},'click-'+path.split('.').at(-1));}
function inventory(){code(`local p=${root}.Panels;p.Visible=true;p.Inventory.Visible=true;p.Store.Visible=false;return true`,'show-inventory');}
const desktop=`local svc=game:GetService('StudioDeviceSimulatorService');local id;for _,v in svc:GetDeviceListAsync() do if svc:GetDeviceInfoAsync(v).Name=='Average Laptop' then id=v;break end end;assert(id);svc:SetDeviceAsync(id);svc:SetResolutionAsync(1280,900);svc:SetScalingModeAsync(Enum.DeviceSimulatorScalingMode.FitToWindow);task.wait(.4);return tostring(workspace.CurrentCamera.ViewportSize)`;
code(desktop,'desktop-1280x900');
code(`local p=${root}.Panels;assert(p.Inventory:GetAttribute('Design')=='action-v1');return {inventory=p.Inventory.Visible,store=p.Store.Visible}`,'design-contract');
const visibility=code(`local p=${root}.Panels;return {inventory=p.Inventory.Visible,store=p.Store.Visible}`,'initial-visible');if(visibility.inventory)click('Panels.Inventory.Close');if(visibility.store)click('Panels.Store.Close');click('Lobby.Inventory');
const ids=['Verity','Axe','Poison','Burst','Cell','Vampire','Acid','Blade','WDC','Orbit','Ray','Laser'];
for(const id of (process.argv.includes('--resume-after-equip')?[]:ids)){
 click('Panels.Inventory.Content.BallsPage.Grid.'+id);
 click('Panels.Inventory.Content.BallsPage.Details.Equip');
 code(`local p=${root}.Panels.Inventory.Content.BallsPage;assert(p.Details.Equipped.Text==${JSON.stringify('Equipped: '+id)});assert(p.Grid[${JSON.stringify(id)}].EquippedMark.Visible);assert(p.Details.Weapon.Visible==${id==='Axe'||id==='Blade'});assert(p.Details.Kit.Text==${JSON.stringify((id==='Axe'||id==='Blade'?'ANCHOR':'DRIFT')+' KIT')});return true`,'equip-'+id);
}
click('Panels.Inventory.Content.BallsPage.Grid.Axe');
code(`local c=${root}.Panels.Inventory.Content;c.CanvasPosition=Vector2.zero;return true`,'inventory-top');capture('inventory-desktop');
for(const category of ['Explosions','Flyers','Fusion']){click('Panels.Inventory.'+category);code(`assert(${root}.Panels.Inventory.Content.Page${category}.Visible);return true`,'category-'+category);capture(category.toLowerCase());}
click('Panels.Inventory.SwitchMenu');capture('store-desktop');
click('Panels.Store.Content.Offers.LaserOffer.ViewLaser');
code(`local p=${root}.Panels;assert(p.Inventory.Visible and p.Inventory.Content.BallsPage.Visible);assert(p.Inventory.Content.BallsPage.Details:FindFirstChild('Name').Text=='Laser Ball');return true`,'store-laser-route');
click('Panels.Inventory.SwitchMenu');click('Panels.Store.Content.Offers.BalloonsOffer.ViewBalloons');
code(`assert(${root}.Panels.Inventory.Content.PageFlyers.Visible);return true`,'store-flyer-route');
click('Panels.Inventory.Balls');
code(readFileSync('tools/qa/devices/phone.luau','utf8'),'phone-emulator');
code('task.wait(.4);return true','phone-settle');phoneInput=false;
code(`local c=${root}.Panels.Inventory.Content;c.CanvasPosition=Vector2.zero;return true`,'phone-top');capture('inventory-phone-top');
reveal('Panels.Inventory.Content.BallsPage.Details.Equip');capture('inventory-phone-detail');
const phone=code(`local p=${root}.Panels.Inventory;local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local o=p.AbsolutePosition-g.AbsolutePosition;assert(o.X>=0 and o.Y>=0 and o.X+p.AbsoluteSize.X<=g.AbsoluteSize.X+1 and o.Y+p.AbsoluteSize.Y<=g.AbsoluteSize.Y+1,'Window bounds');local sizes={};for _,b in {p.Close,p.SwitchMenu,p.Balls,p.Explosions,p.Flyers,p.Fusion,p.Content.BallsPage.Details.Equip} do assert(b.AbsoluteSize.Y>=43.5,b.Name..' too small');sizes[b.Name]=b.AbsoluteSize.Y end;local d=p.Content.BallsPage.Details;assert(d.Description.Position.Y.Offset+d.Description.Size.Y.Offset<=d.Equipped.Position.Y.Offset,'Description overlaps equipped');return {viewport=tostring(g.AbsoluteSize),targets=sizes,outerScroll=p.Content.AbsoluteCanvasSize.Y>p.Content.AbsoluteSize.Y,physicalDevice=false}`,'phone-bounds');
click('Panels.Inventory.SwitchMenu');capture('store-phone-top');reveal('Panels.Store.Content.Offers.ParasolOffer.ViewParasol');capture('store-phone-offers');click('Panels.Store.Content.Offers.ParasolOffer.ViewParasol');
code(`assert(${root}.Panels.Inventory.Content.PageFlyers.Visible);return true`,'phone-store-route');
code(desktop,'desktop-restored');phoneInput=false;
click('Panels.Inventory.Balls');click('Panels.Inventory.Content.BallsPage.Grid.Axe');click('Panels.Inventory.Content.BallsPage.Details.Equip');
code(`local c=${root}.Panels.Inventory.Content;c.CanvasPosition=Vector2.zero;return true`,'final-inventory-top');capture('inventory-final');
const regression=code(readFileSync('tools/qa/fixtures/client-regressions.luau','utf8'),'client-regressions');
writeFileSync(outputFile('action-v1-result.json'),JSON.stringify({design:'action-v1',allAppearancesEquipped:ids,categories:true,storeBallRoute:true,storeFlyerRoutes:true,phoneMouseInput:'Actual mouse injection at observed button centers in landscape emulation',phone,regression},null,2));
