import {writeFileSync,readFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
const studio=process.argv[2];
if(!studio)throw Error('Verified Studio ID required');
let n=0;
function call(name,args,label){const file='tools/visual-sequence-request.json';writeFileSync(file,JSON.stringify({name,arguments:{studio_id:studio,...args}}));const out=`test-evidence/visual-qa-${String(++n).padStart(2,'0')}-${label}.json`;const r=spawnSync(process.execPath,['tools/studio-mcp.mjs','call',file,out],{encoding:'utf8',windowsHide:true});if(r.status)throw Error(r.stdout+r.stderr);console.log(label, out);return JSON.parse(readFileSync(out,'utf8'));}
function click(control){return call('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',instance_path:'LocalPlayer.PlayerGui.BallVsSpace.Controls.'+control}]},'click-'+control);}
function waitPhase(phase,seconds=20){const r=call('execute_luau',{datamodel_type:'Client',code:`local g=game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("BallVsSpace",10);local deadline=os.clock()+${seconds};repeat task.wait(.1) until g:GetAttribute("Phase")==${JSON.stringify(phase)} or os.clock()>=deadline;return {phase=g:GetAttribute("Phase")}`},'wait-'+phase);const d=JSON.parse(r.result.content.find(x=>x.type==='text').text);if(d.phase!==phase)throw Error('Unexpected phase '+d.phase);}
call('start_stop_play',{is_start:true},'start');
call('execute_luau',{datamodel_type:'Client',code:'local s=game:GetService("StudioDeviceSimulatorService");s:SetScalingModeAsync(Enum.DeviceSimulatorScalingMode.ActualResolution);task.wait(.3);return tostring(workspace.CurrentCamera.ViewportSize)'},'capture-scale');
click('Right');
waitPhase('Draft');
call('screen_capture',{capture_id:'reference-draft'},'draft');
click('Left');
click('Primary');
waitPhase('Aim');
call('screen_capture',{capture_id:'reference-aim'},'aim');
click('Right');
click('Primary');
waitPhase('Battle');
call('screen_capture',{capture_id:'reference-battle'},'battle');
console.log('Actual Practice/card/lock/turn/aim interactions completed.');
