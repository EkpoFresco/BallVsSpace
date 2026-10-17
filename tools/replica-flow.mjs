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
capture('lobby');click('Lobby.Inventory','inventory');capture('lobby-collection');click('Collection.Close','collection-close');
click('Controls.Right','practice');
for(let round=1;round<=3;round++){
 const entering=wait(['Draft','MatchResult'],15);
 if(entering==='MatchResult'){
  capture('match-result');
  const outcome=code('return {phase=workspace:GetAttribute("BVSPhase"),tick=workspace:GetAttribute("BVSTick"),a=workspace:GetAttribute("BVSCountA"),b=workspace:GetAttribute("BVSCountB"),hash=workspace:GetAttribute("BVSBoardHash"),reason=workspace:GetAttribute("BVSResultReason"),completed=workspace:GetAttribute("BVSCompletedMatches")}','match-outcome');
  writeFileSync('test-evidence/replica-practice-result.json',JSON.stringify(outcome,null,2));break;
 }
 capture('draft-'+round);
 if(round===1){click('Draft.AllBalls','all-balls');capture('collection');click('Collection.Acid','choose-acid');click('Collection.Confirm','confirm-acid');}
 else click('Draft.'+(round===2?'Axe':'Poison'),'choose-'+round);
 wait(['Aim'],12);
 const selected=code('return game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace:GetAttribute("SelectedAppearance")','selected-'+round);
 if(selected!==(round===1?'Acid':round===2?'Axe':'Poison'))throw Error('Appearance mismatch '+selected);
 if(round===1){
  rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',instance_path:'LocalPlayer.PlayerGui.BVSReferenceCourt.ReferenceCanvas.Playfield.InnerShadow'}]},'aim-on-court');
  const angle=code('task.wait(.4);return game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace:GetAttribute("AimAngle")','aim-angle');
  if(angle===0||angle===180)throw Error('Court aiming did not change angle');
 }
 capture('aim-'+round);click('Controls.Primary','lock-aim-'+round);
 wait(['Battle'],10);code('task.wait(7);return true','battle-progress-'+round);capture('battle-'+round);
 const phase=wait(['RoundResult','MatchResult'],30);capture('result-'+round);
 const outcome=code('return {phase=workspace:GetAttribute("BVSPhase"),tick=workspace:GetAttribute("BVSTick"),a=workspace:GetAttribute("BVSCountA"),b=workspace:GetAttribute("BVSCountB"),hash=workspace:GetAttribute("BVSBoardHash"),reason=workspace:GetAttribute("BVSResultReason"),completed=workspace:GetAttribute("BVSCompletedMatches")}','outcome-'+round);
 if(phase==='MatchResult'){writeFileSync('test-evidence/replica-practice-result.json',JSON.stringify(outcome,null,2));break;}
}
rpc('get_console_output',{},'console');
