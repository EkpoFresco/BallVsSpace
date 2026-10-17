import {writeFileSync,readFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
const id=process.argv[2];if(!id)throw Error('Studio id required');
function rpc(name,args,label){let f='tools/replica-mobile-request.json',out='test-evidence/replica-mobile-'+label+'.json';writeFileSync(f,JSON.stringify({name,arguments:{studio_id:id,...args}}));let r=spawnSync(process.execPath,['tools/studio-mcp.mjs','call',f,out],{encoding:'utf8',windowsHide:true});if(r.status)throw Error(r.stdout+r.stderr);console.log(label);const txt=JSON.parse(readFileSync(out,'utf8')).result.content.find(c=>c.type==='text')?.text;try{return JSON.parse(txt)}catch{return txt}}
const code=(c,label)=>rpc('execute_luau',{datamodel_type:'Client',code:c},label);
const click=(path,label)=>rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',instance_path:'LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.'+path}]},label);
const capture=label=>rpc('screen_capture',{capture_id:'mobile-'+label},label);
function wait(phase,seconds=15){const p=code(`local g=game:GetService('Players').LocalPlayer.PlayerGui.BallVsSpace;local untilTime=os.clock()+${seconds};repeat task.wait(.1) until g:GetAttribute('Phase')=='${phase}' or os.clock()>untilTime;return g:GetAttribute('Phase')`,'wait-'+phase);if(p!==phase)throw Error('Expected '+phase+', got '+p)}
wait('Lobby');
click('Settings','settings-open');click('SettingsPanel.Territory','territory-on');click('SettingsPanel.Motion','motion-on');
code(`local p=game:GetService('Players').LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.SettingsPanel;assert(p.Territory.Text=='Territory overlay: ON');assert(p.Motion.Text=='Reduced motion: ON');return {settingsPass=true}`,'settings-assert');capture('settings');
click('SettingsPanel.Territory','territory-off');click('SettingsPanel.Motion','motion-off');click('Settings','settings-close');
code(readFileSync('tools/device-phone.luau','utf8'),'portrait-device');capture('portrait-lobby');
click('Controls.Right','practice');wait('Draft');capture('portrait-draft');click('Draft.Cell','choose-cell');wait('Aim');capture('portrait-aim');
const layout=code(`local p=game:GetService('Players').LocalPlayer.PlayerGui;local v=workspace.CurrentCamera.ViewportSize;local court=p.BVSReferenceCourt.ReferenceCanvas.Court;local b=p.BallVsSpace.ReferenceCanvas.Controls.Primary;assert(court.AbsolutePosition.X>=0 and court.AbsolutePosition.X+court.AbsoluteSize.X<=v.X+.1);assert(b.AbsolutePosition.Y+b.AbsoluteSize.Y<=v.Y);return {viewport=tostring(v),courtPosition=tostring(court.AbsolutePosition),courtSize=tostring(court.AbsoluteSize),primarySize=tostring(b.AbsoluteSize),portraitBounds=true}`,'portrait-bounds');
click('Controls.Primary','lock');wait('Battle');code('task.wait(2);return true','progress');capture('portrait-battle');
code(readFileSync('tools/device-landscape.luau','utf8'),'landscape-device');capture('landscape-battle');
code(`local p=game:GetService('Players').LocalPlayer.PlayerGui;local v=workspace.CurrentCamera.ViewportSize;local c=p.BVSReferenceCourt.ReferenceCanvas.Court;assert(c.AbsolutePosition.Y>=0 and c.AbsolutePosition.Y+c.AbsoluteSize.Y<=v.Y+.1);return {viewport=tostring(v),courtSize=tostring(c.AbsoluteSize),landscapeBounds=true}`,'landscape-bounds');
rpc('get_console_output',{},'console');
