import {readFileSync,writeFileSync} from 'node:fs';
import {gameRoot,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2],prefix=process.argv[3]||'action-theme-final-regression';
if(!studio)throw Error('Explicit verified Studio ID required');
process.chdir(gameRoot);
const rpc=createQa(studio,prefix);
const fixture=(name,datamodel_type)=>rpc('execute_luau',{datamodel_type,code:readFileSync('tools/qa/fixtures/'+name+'.luau','utf8')},name);
const clientCode=(code,label)=>rpc('execute_luau',{datamodel_type:'Client',code},label);
function click(path,label){
 const point=clientCode(`local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local n=g.ReferenceCanvas;for part in string.gmatch(${JSON.stringify(path)},'[^.]+') do n=n:FindFirstChild(part);assert(n) end;local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=g.Parent;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy();local p=n.AbsolutePosition+n.AbsoluteSize/2+offset;return {x=p.X,y=p.Y}`,label+'-point');
 rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',...point},{action:'wait',wait_time_ms:300}]},label);
}
function phase(expected){clientCode(`local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local deadline=os.clock()+8;repeat task.wait(.1) until g:GetAttribute('Phase')==${JSON.stringify(expected)} or os.clock()>deadline;assert(g:GetAttribute('Phase')==${JSON.stringify(expected)});return true`,'wait-'+expected);}
phase('Lobby');click('Lobby.Practice','practice');phase('Draft');click('Draft.Axe','choose-axe');phase('Aim');
click('HelpButton','open-help');
const help=clientCode(`local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local p=g.ReferenceCanvas.Panels['How to play'];task.wait(.2);assert(p.Visible);assert(math.abs(p.AbsolutePosition.X+p.AbsoluteSize.X/2-g.AbsolutePosition.X-g.AbsoluteSize.X/2)<1,'Help not centered');for _,n in p:GetDescendants() do if n:IsA('TextLabel') and n.Visible and n.Text~='' then assert(n.TextFits,n:GetFullName()..' clipped') end end;assert(not game:GetService('GuiService').TouchControlsEnabled);return {textFits=true,centered=true,nativeMovementHidden=true}`,'help-layout');
rpc('screen_capture',{capture_id:'centered-help-phone'},'centered-help-phone');click('Panels.How to play.Close','close-help');
const client=fixture('client-regressions','Client');
const renderer=fixture('render-benchmark','Client');
rpc('start_stop_play',{is_start:false},'stop-play');
const logic=fixture('logic','Edit');
const presentation=fixture('presentation-contracts','Edit');
const start=fixture('multiplayer-smoke','Edit');
let observed;
for(let i=0;i<24;i++){
 observed=rpc('execute_luau',{datamodel_type:'Edit',code:`local deadline=os.clock()+10;repeat task.wait(.5) until game:GetAttribute('BVSReplicaMultiplayerCompletedRun')==game:GetAttribute('BVSReplicaMultiplayerRun') or os.clock()>deadline;return {runId=game:GetAttribute('BVSReplicaMultiplayerRun'),completedRunId=game:GetAttribute('BVSReplicaMultiplayerCompletedRun'),result=game:GetAttribute('BVSReplicaMultiplayerResult')}`},'multiplayer-progress-'+i);
 if(observed.completedRunId===start.runId)break;
}
if(observed.completedRunId!==start.runId)throw Error('Fresh multiplayer run did not complete');
const multiplayer=JSON.parse(observed.result);
if(multiplayer.players!==2||multiplayer.matches!==1||multiplayer.mismatches!==0||multiplayer.visualFailures!==0||multiplayer.aborted!==0)throw Error('Multiplayer regression: '+observed.result);
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({help,client,renderer,logic,presentation,multiplayer,runId:start.runId},null,2));
console.log('Final regression passed',multiplayer);
