import {readFileSync,writeFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import path from 'node:path';
import {gameRoot,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2],prefix=process.argv[3]??'world-roundtrip';
if(!studio)throw Error('Explicit verified local Studio ID required');
const rpc=createQa(studio,prefix);
const inspect=`assert(game.PlaceId==0);local r=assert(workspace:FindFirstChild('BVSCourt'));local parts,prompts=0,0
for _,n in r:GetDescendants()do
 assert(not n:IsA('LuaSourceContainer'),'Runtime code in authored world')
 if n:IsA('BasePart')then assert(n.Anchored);parts+=1 end
 if n:IsA('ProximityPrompt')then assert(n:GetAttribute('BVSAction'));prompts+=1 end
end
assert(not game.ServerScriptService.Server.Services:FindFirstChild('CourtService'))
assert(r.CourtFloor.Position.Y>r.ArenaInset.Position.Y+r.ArenaInset.Size.Y/2)
assert(r.QueuePad.Position.Y>r.ArenaInset.Position.Y+r.ArenaInset.Size.Y/2)
return {identity=r:GetDebugId(16),parts=parts,prompts=prompts,descendants=#r:GetDescendants(),savedScene=true}`;
const before=rpc('execute_luau',{datamodel_type:'Edit',code:inspect},'edit-before');
const logic=rpc('execute_luau',{datamodel_type:'Edit',code:readFileSync(path.join(gameRoot,'tools/qa/fixtures/logic.luau'),'utf8')},'logic');
rpc('screen_capture',{capture_id:prefix+'-edit-before'},'map-edit');
let running=false,client;
try{
 rpc('start_stop_play',{is_start:true},'play');running=true;
 rpc('execute_luau',{datamodel_type:'Client',code:"local s=game:GetService('StudioDeviceSimulatorService');s:SetDeviceAsync('average_laptop');s:SetResolutionAsync(1280,900);task.wait(.5);return true"},'desktop');
 const run=spawnSync(process.execPath,[path.join(gameRoot,'tools/qa/lobby.mjs'),studio,prefix+'-lobby'],{encoding:'utf8',windowsHide:true,timeout:180000});
 if(run.status!==0)throw Error(run.stdout+run.stderr);
 client=rpc('execute_luau',{datamodel_type:'Client',code:readFileSync(path.join(gameRoot,'tools/qa/fixtures/client-regressions.luau'),'utf8')},'client-lifecycle');
}finally{if(running)rpc('start_stop_play',{is_start:false},'stop');}
const after=rpc('execute_luau',{datamodel_type:'Edit',code:inspect},'edit-after');
if(JSON.stringify(before)!==JSON.stringify(after))throw Error('Edit scene changed after Play');
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({before,after,logic,client,roundTrip:true,scope:'Saved primary file opened fresh; static Edit scene, actual E prompt input, Practice start, UI lifecycle and return to Edit'},null,2));
console.log('Static map, lobby interactions and Edit/Play/Stop round trip passed.');
