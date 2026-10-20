// Real input regression for dismissal, scroll-edge selection and grouped Store offers.
import {writeFileSync} from 'node:fs';
import {outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2],prefix=process.argv[3]??'menu-regression';
if(!studio)throw Error('Explicit verified local Studio ID required');
const rpc=createQa(studio,prefix);
const run=(code,label)=>rpc('execute_luau',{datamodel_type:'Client',code},label);
const root='game.Players.LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas';
const checks=[];
function click(path,label,dx=.5,dy=.5){
 const p=run(`local n=${root};for part in string.gmatch(${JSON.stringify(path)},'[^.]+') do n=n:FindFirstChild(part);assert(n,part) end
 local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=g.Parent;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy()
 local p=n.AbsolutePosition+Vector2.new(n.AbsoluteSize.X*${dx},n.AbsoluteSize.Y*${dy})+offset;return {x=p.X,y=p.Y}`,'point-'+label);
 rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',...p},{action:'wait',wait_time_ms:180}]},label);
}
for(const [name,width,height] of [['short',568,320],['desktop',900,650],['wide',1920,1080]]){
 run(`local m=game.Players.LocalPlayer.PlayerScripts:FindFirstChild('QAScaleReview');if m then require(m).destroy();m:Destroy() end
 local s=game:GetService('StudioDeviceSimulatorService');s:SetDeviceAsync('average_laptop');s:SetResolutionAsync(${width},${height});task.wait(.3);return true`,'device-'+name);
 const open=run(`local p=${root}.Panels;for _,n in p:GetChildren() do if n:IsA('Frame')and n.Visible then return n.Name end end;return ''`,'open-'+name);
 if(open)click('Panels.'+open+'.Close','reset-'+name);
 click('Lobby.Inventory','inventory-'+name);
 click('Panels.Inventory.Balls','balls-'+name);
 run(`local g=${root}.Panels.Inventory.Content.BallsPage.Grid;g.CanvasPosition=Vector2.zero;task.wait(.1);return true`,'scroll-top-'+name);
 click('Panels.Inventory.Content.BallsPage.Grid.Verity','select-left-'+name);
 click('Panels.Inventory.Content.BallsPage.Grid','empty-grid-'+name,0,0);
 click('Panels.Inventory','empty-header-'+name,.52,.02);
 checks.push(run(`local p=${root}.Panels.Inventory;assert(p.Visible,'Empty inside click dismissed Inventory');local g=p.Content.BallsPage.Grid
 local n=g.Verity;assert(n:FindFirstChild('Selected').Visible,'First card not selected');assert(n.Outline.Edge.BorderStrokePosition==Enum.BorderStrokePosition.Inner,'Border must be inset')
 assert(n.AbsolutePosition.X>=g.AbsolutePosition.X and n.AbsolutePosition.Y>=g.AbsolutePosition.Y)
 assert(p.Close.Cross:IsA('TextLabel') and p.Close.Cross.Text=='×')
 g.CanvasPosition=Vector2.new(0,g.AbsoluteCanvasSize.Y);task.wait(.1);return {device=${JSON.stringify(name)},insideInventory=true,selectionInset=true,closeMatches=true}`,'inventory-check-'+name));
 click('Panels.Inventory.Content.BallsPage.Grid.Laser','select-last-'+name);
 checks.push(run(`local p=${root}.Panels.Inventory;local g=p.Content.BallsPage.Grid;local n=g.Laser
 assert(p.Visible and n:FindFirstChild('Selected').Visible);assert(n.AbsolutePosition.Y+n.AbsoluteSize.Y<=g.AbsolutePosition.Y+g.AbsoluteSize.Y+.5,'Last row clipped')
 return {device=${JSON.stringify(name)},lastRowFullyVisible=true}`,'scroll-check-'+name));
 rpc('screen_capture',{capture_id:prefix+'-inventory-'+name},'inventory-image-'+name);
 click('Panels.Inventory.SwitchMenu','store-'+name);
 click('Panels.Store','empty-store-'+name,.52,.02);
 click('Panels.Store.Content.Offers.LaserOffer','card-padding-'+name,.02,.98);
 checks.push(run(`local p=${root}.Panels.Store;assert(p.Visible,'Empty inside click dismissed Store');local g=p.Content.Offers.LaserOffer;assert(g.Laser.Parent==g and g.ViewLaser.Parent==g)
 return {device=${JSON.stringify(name)},insideStore=true,groupedOffer=true}`,'store-check-'+name));
 rpc('screen_capture',{capture_id:prefix+'-store-'+name},'store-image-'+name);
 click('Panels.Store.Content.Offers.LaserOffer.ViewLaser','view-'+name);
 run(`local p=${root}.Panels.Inventory;assert(p.Visible and p.Content.BallsPage.Details:FindFirstChild('Name').Text=='Laser Ball');return true`,'view-check-'+name);
 click('Panels.Inventory.SwitchMenu','store-return-'+name);
 click('Panels.Store.Explosions','category-'+name);
 click('Panels.Inventory.SwitchMenu','category-return-'+name);
 checks.push(run(`local p=${root}.Panels.Store;assert(p.Visible);local c=p.Explosions.ButtonFill:FindFirstChildOfClass('UIGradient').Color.Keypoints[1].Value
 assert(c~=Color3.fromRGB(142,239,229),'Store retained an Inventory-only active tab');return {device=${JSON.stringify(name)},categoryReturn=true}`,'category-check-'+name));
 click('Panels.Store.Close','close-'+name);
 run(`assert(not ${root}.Panels.Visible);return true`,'close-check-'+name);
}
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({scope:'Actual mouse input at three emulated landscape/desktop resolutions',checks,physicalTouch:false},null,2));
