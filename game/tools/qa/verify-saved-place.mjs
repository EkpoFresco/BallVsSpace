// Read-only identity/source check after opening the canonical binary from disk.
import {readFileSync,writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {gameRoot,sourceInventory,luauString as quote,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2],prefix=process.argv[3]??'saved-place';
if(!studio)throw Error('Explicit verified Studio ID required');
const rpc=createQa(studio,prefix),files=sourceInventory();
for(let i=0;i<files.length;i+=6){
 const code=['assert(game.PlaceId==0,"Not the local place")'];
 for(const f of files.slice(i,i+6)){
  code.push(`do local n=game:GetService(${quote(f.parts[0])})`);
  for(const p of f.parts.slice(1))code.push(`n=n:FindFirstChild(${quote(p)});assert(n,${quote(f.relative)})`);
  code.push(`assert(n.ClassName==${quote(f.cls)});assert(string.gsub(n.Source,'\\r','')==string.gsub(${quote(f.source)},'\\r',''),${quote('Saved source differs: '+f.relative)});end`);
 }
 code.push('return true');rpc('execute_luau',{datamodel_type:'Edit',code:code.join('\n')},'source-'+i);
}
const identity=rpc('execute_luau',{datamodel_type:'Edit',code:`local c=require(game.ReplicatedStorage.Shared.Config);local h=require(game.ReplicatedStorage.Shared.HeroDefinitions);assert(c.BuildVersion=='0.4.2-armory-polish' and #h.ids==30);assert(not game.ServerScriptService.Server.Services:FindFirstChild('AbilityService'));local w=workspace.BVSCourt;return {placeId=game.PlaceId,build=c.BuildVersion,rules=c.RulesVersion,motion=c.MotionVersion,heroes=#h.ids,worldDescendants=#w:GetDescendants()}`},'identity');
const file=gameRoot+'/places/BallVsSpace.rbxl';
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({studio,canonicalScripts:files.length,allSourcesMatch:true,file,sha256:createHash('sha256').update(readFileSync(file)).digest('hex'),identity},null,2));
console.log('Saved place matches',files.length,'canonical scripts');
