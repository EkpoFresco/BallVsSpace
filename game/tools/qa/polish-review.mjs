import {readFileSync,writeFileSync} from 'node:fs';
import {createQa} from '../studio/client.mjs';
import {gameRoot,outputFile} from '../lib/project.mjs';
const [studio,mode,prefix='polish-review']=process.argv.slice(2);
if(!studio)throw Error('Explicit Studio ID required');
const rpc=createQa(studio,prefix);
if(!['territory-benchmark','animation-polish','camera-polish','respawn'].includes(mode))throw Error('Unknown review mode');
let result;
if(mode==='respawn'){
 rpc('execute_luau',{datamodel_type:'Client',code:`local p=game.Players.LocalPlayer;assert(p.PlayerGui.BallVsSpace:GetAttribute('Phase')=='Lobby');p.Character:SetAttribute('QAOldCharacter',true);p.PlayerGui.BallVsSpace:SetAttribute('QAOriginalGui',true);return true`},'before-reset');
 rpc('execute_luau',{datamodel_type:'Server',code:`assert(game.PlaceId==0);local players=game.Players:GetPlayers();assert(#players==1);players[1]:LoadCharacterAsync();return true`},'reset');
 result=rpc('execute_luau',{datamodel_type:'Client',code:`local p=game.Players.LocalPlayer;local deadline=os.clock()+15;repeat task.wait(.1) until (p.Character and not p.Character:GetAttribute('QAOldCharacter') and p.Character:FindFirstChildOfClass('Humanoid') and workspace.CurrentCamera.CameraSubject==p.Character:FindFirstChildOfClass('Humanoid')) or os.clock()>deadline;local h=p.Character:FindFirstChildOfClass('Humanoid');local g=p.PlayerGui.BallVsSpace;assert(not p.Character:GetAttribute('QAOldCharacter'));assert(workspace.CurrentCamera.CameraSubject==h and workspace.CurrentCamera.CameraType==Enum.CameraType.Custom);assert(h.WalkSpeed>0 and h.JumpPower>0 and h.JumpHeight>0);assert(g:GetAttribute('QAOriginalGui') and g:GetAttribute('Phase')=='Lobby' and g.ReferenceCanvas.Lobby.Practice.Visible);local counts={BallVsSpace=0,BVSBallLabels=0};for _,n in p.PlayerGui:GetChildren() do if counts[n.Name] then counts[n.Name]+=1 end end;assert(counts.BallVsSpace==1 and counts.BVSBallLabels==1);g:SetAttribute('QAOriginalGui',nil);return {actualCharacterResets=1,cameraSubjectRestored=true,movementAvailable=true,guiRetained=true,guiCounts=counts}`},'after-reset');
}else{
 result=rpc('execute_luau',{datamodel_type:'Client',code:readFileSync(gameRoot+'/tools/qa/fixtures/'+mode+'.luau','utf8')},mode);
}
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify(result,null,2));
console.log(mode,result);
