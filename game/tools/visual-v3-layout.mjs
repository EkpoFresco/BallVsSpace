import {readFileSync,writeFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
const studio=process.argv[2],prefix=process.argv[3]||'visual-v3-layout';
if(!studio)throw Error('Explicit Studio ID required');
let n=0;
function rpc(name,args,label){
 const request='tools/visual-v3-layout-request.json',out=`test-evidence/${prefix}-${String(++n).padStart(2,'0')}-${label}.json`;
 writeFileSync(request,JSON.stringify({name,arguments:{studio_id:studio,...args}}));
 const r=spawnSync(process.execPath,['tools/studio-mcp.mjs','call',request,out],{encoding:'utf8',windowsHide:true});
 if(r.status)throw Error(r.stdout+r.stderr);console.log(label);
 const value=JSON.parse(readFileSync(out,'utf8')).result.content.find(c=>c.type==='text')?.text;
 try{return JSON.parse(value)}catch{return value}
}
const code=(value,label)=>rpc('execute_luau',{datamodel_type:'Client',code:value},label);
const click=(path,label)=>rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',instance_path:'LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.'+path}]},label);
const capture=label=>rpc('screen_capture',{capture_id:label},label);
const g='game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace';
function device(name){code(readFileSync('tools/device-'+name+'.luau','utf8'),'device-'+name);code('task.wait(.5);return true','settled-'+name)}
function phase(name){const p=code(`local g=${g};local limit=os.clock()+12;repeat task.wait(.1) until g:GetAttribute("Phase")=="${name}" or os.clock()>limit;return g:GetAttribute("Phase")`,'wait-'+name);if(p!==name)throw Error('Expected '+name+', got '+p)}
function bounds(name,targets){return code(`local g=${g};local panel=g.ReferenceCanvas.Panels[${JSON.stringify(name)}];local origin=panel.AbsolutePosition-g.AbsolutePosition;local extent=origin+panel.AbsoluteSize;assert(panel.Visible);assert(origin.X>=0 and origin.Y>=0 and extent.X<=g.AbsoluteSize.X+1 and extent.Y<=g.AbsoluteSize.Y+1,'Panel clipped');local sizes={};for _,path in {${targets.map(x=>JSON.stringify(x)).join(',')}} do local b=panel;for part in string.gmatch(path,'[^.]+') do b=b:FindFirstChild(part) end;assert(b.AbsoluteSize.Y>=43.5,path..' target too small: '..b.AbsoluteSize.Y);local position=b.AbsolutePosition-g.AbsolutePosition;assert(position.X>=0 and position.Y>=0 and position.X+b.AbsoluteSize.X<=g.AbsoluteSize.X+1 and position.Y+b.AbsoluteSize.Y<=g.AbsoluteSize.Y+1,path..' clipped');sizes[path]=b.AbsoluteSize.Y end;return {viewport=tostring(g.AbsoluteSize),panel=tostring(panel.AbsoluteSize),targets=sizes,physicalDevice=false}`,'bounds-'+name.replaceAll(' ','-'))}
phase('Lobby');device('reference');click('Lobby.Inventory','inventory-desktop');device('phone');capture('inventory-portrait');
const inventory=bounds('Inventory',['Close','BallsPage.Details.Equip','Balls','Explosions','Flyers','Fusion']);
click('Panels.Inventory.Close','close-phone-attempt');
const phoneClick=code(`task.wait(.2);return not ${g}.ReferenceCanvas.Panels.Visible`,'phone-close-result');
device('reference');if(!phoneClick)click('Panels.Inventory.Close','close-desktop');
click('Lobby.Store','store-desktop');device('phone');capture('store-portrait');
const store=bounds('Store',['Close','Offers.ViewLaser','Offers.ViewRay','Offers.ViewBalloons','Offers.ViewParasol']);
device('landscape');capture('store-landscape');bounds('Store',['Close','Offers.ViewLaser']);
device('reference');click('Panels.Store.Close','close-store');device('phone');capture('lobby-portrait');
code(`local r=${g}.ReferenceCanvas;assert(r.Controls.Left.AbsoluteSize.Y>=43.5 and r.Controls.Right.AbsoluteSize.Y>=43.5);assert(r.Lobby.Invite.Visible);return true`,'lobby-touch-targets');
device('reference');click('Controls.Right','practice');phase('Draft');
const before=code(`local out={};for _,b in ${g}.ReferenceCanvas.Draft:GetChildren() do if b:IsA('TextButton') and b:FindFirstChild('PreviewBackground') then table.insert(out,b.Name) end end;table.sort(out);return out`,'before-reroll');
click('Draft.Reroll','reroll');
const after=code(`local out={};for _,b in ${g}.ReferenceCanvas.Draft:GetChildren() do if b:IsA('TextButton') and b:FindFirstChild('PreviewBackground') then table.insert(out,b.Name) end end;table.sort(out);return out`,'after-reroll');
if(JSON.stringify(Object.values(before).sort())===JSON.stringify(Object.values(after).sort())||new Set(Object.values(after)).size!==3)throw Error('Reroll failed');
device('phone');capture('draft-portrait');device('reference');click('Draft.AllBalls','all-balls');click('Collection.Blade','blade');click('Collection.Confirm','confirm-blade');phase('Aim');device('phone');capture('aim-portrait');
code(`local p=game:GetService('Players').LocalPlayer;local g=p.PlayerGui.BallVsSpace;local b=p.PlayerGui.BVSBallLabels.ReferenceCanvas.Ball1;local full=g.AbsoluteSize;local primary=g.ReferenceCanvas.Controls.Primary;local court=p.PlayerGui.BVSReferenceCourt.ReferenceCanvas.Court;local origin=court.AbsolutePosition-g.AbsolutePosition;assert(origin.X>=0 and origin.X+court.AbsoluteSize.X<=full.X+.1);assert(primary.AbsoluteSize.Y>=43.5);local screen=b.AbsolutePosition-g.AbsolutePosition+b.AbsoluteSize/2+Vector2.new(80,-80);local angle=require(p.PlayerScripts.Client.Controllers.AimController).angle(full,screen,-19,0);assert(angle and math.abs(angle-315)<.5);return {aimDiagonal=angle,primaryHeight=primary.AbsoluteSize.Y}`,'aim-bounds');
device('reference');click('Controls.Primary','lock');phase('Battle');device('phone');capture('battle-portrait');device('landscape');capture('battle-landscape');device('reference');
rpc('get_console_output',{},'console');
writeFileSync(`test-evidence/${prefix}-result.json`,JSON.stringify({inventory,store,phoneCloseInjectionWorked:phoneClick,reroll:{before,after},court:true,aim:true,physicalTouch:false},null,2));
