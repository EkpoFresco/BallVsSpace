import {writeFileSync,readFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
const studio=process.argv[2],prefix=process.argv[3]||'replica-flow';if(!studio)throw Error('Explicit Studio ID required');
let n=0;
function rpc(name,args,label){
 const req='tools/replica-flow-request.json',out=`test-evidence/${prefix}-${String(++n).padStart(2,'0')}-${label}.json`;
 writeFileSync(req,JSON.stringify({name,arguments:{studio_id:studio,...args}}));
 const r=spawnSync(process.execPath,['tools/studio-mcp.mjs','call',req,out],{encoding:'utf8',windowsHide:true});
 if(r.status)throw Error(r.stdout+r.stderr);console.log(label,out);
 const result=JSON.parse(readFileSync(out,'utf8')).result;
 const txt=result.content.find(x=>x.type==='text')?.text;
 try{return JSON.parse(txt);}catch{return txt;}
}
function code(code,label){return rpc('execute_luau',{datamodel_type:'Client',code},label)}
function click(path,label){return rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',instance_path:'LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.'+path}]},label)}
function capture(label){rpc('screen_capture',{capture_id:label},label)}
function wait(phases,seconds=35){const p=JSON.stringify(phases).replaceAll('[','{').replaceAll(']','}');const r=code(`local g=game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace;local untilTime=os.clock()+${seconds};local expected=${p};repeat task.wait(.1) until table.find(expected,g:GetAttribute("Phase")) or os.clock()>untilTime;return {phase=g:GetAttribute("Phase")}`, 'wait-'+phases.join('-'));if(!phases.includes(r.phase))throw Error('Unexpected phase '+r.phase);return r.phase;}

click('Controls.Right','practice');wait(['Draft'],12);click('Draft.AllBalls','open');
code('local c=game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas;assert(c.Collection.Visible and not c.Draft.Visible and c.DraftShade.Visible);return true','modal-stack');capture('compact-picker');
click('Collection.Close','cancel');code('local c=game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas;assert(not c.Collection.Visible and c.Draft.Visible);return true','cancel-restores-draft');
click('Draft.AllBalls','reopen');click('Collection.Burst','select-burst');click('Collection.Confirm','confirm');wait(['Aim'],12);
code('local p=game:GetService("Players").LocalPlayer.PlayerGui;local g=p.BallVsSpace;local c=g.ReferenceCanvas;assert(g:GetAttribute("SelectedAppearance")=="Burst");assert(not c.Collection.Visible and not c.Draft.Visible and not c.DraftShade.Visible);assert(p.BVSBallLabels.ReferenceCanvas.Ball1.Model.WorldModel:FindFirstChild("Burst"));return {stackPass=true,appearance="Burst"}','confirmed-state');capture('burst-aim');
