// Actual Studio input and fresh canonical module tests for weapon rules v2.
import {readFileSync,writeFileSync} from 'node:fs';
import {gameRoot,outputFile,luauString} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2], mode=process.argv[3]??'flow', prefix=process.argv[4]??'weapon-v2-'+mode;
if(!studio)throw Error('Explicit verified Studio ID required');
const rpc=createQa(studio,prefix);
const run=(code,label,type='Client')=>rpc('execute_luau',{datamodel_type:type,code},label);
const capture=label=>rpc('screen_capture',{capture_id:prefix+'-'+label},label);
const root='game.Players.LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas';
const array=x=>Array.isArray(x)?x:Object.values(x??{});
const click=(path,label)=>{
 const point=run(`local n=${root};for part in string.gmatch(${luauString(path)},'[^.]+') do n=n:FindFirstChild(part);assert(n,part) end
 local a=n.Parent;while a do if a:IsA('ScrollingFrame') and a.ScrollingEnabled then local d=n.AbsolutePosition.Y-a.AbsolutePosition.Y;if d<0 or d+n.AbsoluteSize.Y>a.AbsoluteSize.Y then a.CanvasPosition=Vector2.new(0,math.clamp(a.CanvasPosition.Y+d-6,0,math.max(0,a.AbsoluteCanvasSize.Y-a.AbsoluteSize.Y))) end end;a=a.Parent end;task.wait(.1)
 local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=g.Parent;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy();local p=n.AbsolutePosition+n.AbsoluteSize/2+offset;return {x=p.X,y=p.Y}`,'point-'+label);
 rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',...point},{action:'wait',wait_time_ms:180}]},label);
};
function phase(allowed,seconds=12){
 const result=run(`local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local untilTime=os.clock()+${seconds};repeat task.wait(.08) until table.find({${allowed.map(luauString).join(',')}},g:GetAttribute('Phase')) or os.clock()>untilTime;return g:GetAttribute('Phase')`,'wait-'+allowed.join('-'));
 if(!allowed.includes(result))throw Error('Unexpected phase '+result);return result;
}
if(mode==='logic'){
 const result=run(readFileSync(gameRoot+'/tools/qa/fixtures/logic.luau','utf8'),'logic','Edit');
 writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify(result,null,2));console.log('Logic passed',result.passed);
}else if(mode==='roster'||mode==='render'){
 const result=run(readFileSync(gameRoot+'/tools/qa/fixtures/weapon-'+mode+'.luau','utf8'),mode,mode==='roster'?'Edit':'Client');
 writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify(result,null,2));console.log(mode+' passed',result.heroes);
}else if(['client-regressions','render-benchmark','weapon-results'].includes(mode)){
 const result=run(readFileSync(gameRoot+'/tools/qa/fixtures/'+mode+'.luau','utf8'),mode);
 writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify(result,null,2));console.log(mode+' passed',result);
}else if(mode==='flow'){
 run(`local m=game.Players.LocalPlayer.PlayerScripts:FindFirstChild('QAScaleReview');if m then require(m).destroy();m:Destroy() end;local s=game:GetService('StudioDeviceSimulatorService');s:SetDeviceAsync('average_laptop');s:SetResolutionAsync(1280,720);task.wait(.3);return true`,'desktop');
 phase(['Lobby']);capture('lobby');click('Lobby.Inventory','inventory');click('Panels.Inventory.Balls','hero-tab');capture('heroes');click('Panels.Inventory.Close','close');
 click('Lobby.Practice','practice');const rounds=[];
 for(let round=1;round<=3;round++){
  if(phase(['Draft','MatchResult'],10)==='MatchResult')break;
  capture('draft-'+round);
  if(round===1){click('Draft.AllBalls','all-heroes');click('Collection.HeroScroll.Pax','last-hero');capture('collection-last-row');click('Collection.Confirm','choose-pax');}
  else{
   const id=run(`local d=${root}.Draft;for _,n in d:GetChildren() do if n:IsA('TextButton') and n:FindFirstChild('PreviewBackground') then return n.Name end end;error('No offered hero')`,'offered-hero-'+round);
   click('Draft.'+id,'pick-'+id);
  }
  phase(['Aim']);
  const art=run(`local p=game.Players.LocalPlayer;local g=p.PlayerGui.BallVsSpace;local r=p.PlayerGui.BVSBallLabels.ReferenceCanvas;local records={};for i=1,2 do local b=r['Ball'..i];local v=b.Model;assert(v:FindFirstChild('HeroPortrait'),'Missing original portrait');assert(v:GetAttribute('HeroId'),'Missing hero');table.insert(records,{hero=v:GetAttribute('HeroId'),diameter=b.AbsoluteSize.X,health=${root}['PlayerSide'..i].HealthLabel.Text}) end;return records`,'hero-art-'+round);
  capture('aim-'+round);click('Controls.Primary','lock-'+round);phase(['Battle']);
  run('task.wait(7);return true','play-'+round);capture('battle-'+round);
  const resultPhase=phase(['RoundResult','MatchResult'],42);
  rounds.push(run(`local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local r=g.ReferenceCanvas;assert(r.Results.Visible);local reason=workspace:GetAttribute('BVSResultReason');local metric=r.Results.ResultMetric.Text;assert(reason~='simulation_error' and reason~='simulation_failure' and reason~='simulation_debt');if reason=='knockout' or reason=='double_ko' then assert(metric=='KNOCKOUT','Wrong result explanation') end;return {round=${round},tick=workspace:GetAttribute('BVSTick'),reason=reason,metric=metric,a=workspace:GetAttribute('BVSCountA'),b=workspace:GetAttribute('BVSCountB'),hpA=r.PlayerSide1.HealthLabel.Text,hpB=r.PlayerSide2.HealthLabel.Text,heroA=r.PlayerSide1.KitIcon:GetAttribute('HeroId'),heroB=r.PlayerSide2.KitIcon:GetAttribute('HeroId')}`,'result-'+round));
  if(resultPhase!=='MatchResult')capture('result-image-'+round);
  else break;
 }
 phase(['MatchResult'],10);
 let resultActions;
 if(process.argv.includes('--result-actions')){
  const points=run(`local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local r=g.ReferenceCanvas;assert(r.Controls.Left.Visible and r.Controls.Primary.Visible);local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=g.Parent;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy();local function point(n) local p=n.AbsolutePosition+n.AbsoluteSize/2+offset;return {x=p.X,y=p.Y} end
  local s=Instance.new('LocalScript');s.Name='QAResultActions';s.Source=[=[local g=script.Parent.BallVsSpace;local r=g.ReferenceCanvas;local started,restored,balls=false,false,false;local deadline=os.clock()+6;repeat task.wait();if r.Status.Visible and string.find(r.Status.Text,'REPLAY',1,true) and not r.Results.Visible then started=true;local b=script.Parent.BVSBallLabels;balls=balls or (b.Enabled and b.ReferenceCanvas.Ball1.Visible) end;if started and r.Results.Visible and r.Controls.Left.Visible then restored=true end;if restored and r.Controls.Primary.Text=='Queued ✓' then task.wait(.4);g:SetAttribute('QAResultActions',game:GetService('HttpService'):JSONEncode({replayStarted=started,replayBallsVisible=balls,resultRestored=restored,rematchConfirmed=r.Controls.Primary.Text=='Queued ✓'}));return end until os.clock()>deadline]=];s.Parent=g.Parent;return {replay=point(r.Controls.Left),rematch=point(r.Controls.Primary)}`,'result-action-points');
  rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',...points.replay},{action:'wait',wait_time_ms:2300},{action:'mouseButtonClick',mouse_button:'left',...points.rematch},{action:'wait',wait_time_ms:600}]},'replay-and-rematch');
  resultActions=run(`local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local raw=g:GetAttribute('QAResultActions');assert(raw,'Result actions were not observed');local r=game:GetService('HttpService'):JSONDecode(raw);assert(r.replayStarted and r.replayBallsVisible and r.resultRestored and r.rematchConfirmed,raw);return r`,'result-actions');
  capture('match-result');phase(['Draft'],12);
 }else{capture('match-result');phase(['Lobby'],12);}
 const errors=run(`local errors={};for _,m in game:GetService('LogService'):GetLogHistory() do if m.messageType==Enum.MessageType.MessageError then table.insert(errors,m.message) end end;return errors`,'client-errors');
 if(array(errors).length)throw Error('Client errors: '+JSON.stringify(errors));
 writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({rounds,resultActions,actualClicks:true,lastHeroReachable:true,completeMatch:true,clientErrors:errors,physicalDevice:false},null,2));
 console.log('Actual-input match completed',rounds);
}else if(mode==='multiplayer'){
 const start=run(readFileSync(gameRoot+'/tools/qa/fixtures/multiplayer-smoke.luau','utf8'),'start','Edit');
 let observed;
 for(let i=0;i<25;i++){
  observed=run(`local deadline=os.clock()+10;repeat task.wait(.5) until game:GetAttribute('BVSReplicaMultiplayerCompletedRun')==${luauString(start.runId)} or os.clock()>deadline;return {completed=game:GetAttribute('BVSReplicaMultiplayerCompletedRun'),result=game:GetAttribute('BVSReplicaMultiplayerResult')}`,'progress-'+i,'Edit');
  if(observed.completed===start.runId)break;
 }
 if(observed.completed!==start.runId)throw Error('Multiplayer did not complete');
 const result=JSON.parse(observed.result);
 writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({runId:start.runId,result},null,2));
 if(result.players!==2||result.matches!==1||result.mismatches!==0||result.visualFailures!==0||result.aborted!==0)throw Error('Multiplayer failed '+JSON.stringify(result));
 console.log('Two-client match passed',result);
}else throw Error('Unknown mode');
