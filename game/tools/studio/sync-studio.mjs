import {readFileSync,writeFileSync} from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {gameRoot,sourceInventory,luauString as quote,outputFile} from '../lib/project.mjs';
import {callStudio} from './client.mjs';
const studio=process.argv[2];if(!studio)throw Error('Explicit verified local Studio ID required');
const files=sourceInventory();
for(let i=0;i<files.length;i+=6){
 const code=['assert(game.PlaceId==0,"Refusing nonlocal place")','local function folder(p,n) local f=p:FindFirstChild(n);if not f then f=Instance.new("Folder");f.Name=n;f.Parent=p end;return f end','folder(game:GetService("ReplicatedStorage"),"Art");workspace.StreamingEnabled=false;workspace.Gravity=196.2;game:GetService("StarterGui").ScreenOrientation=Enum.ScreenOrientation.LandscapeSensor'];
 for(const f of files.slice(i,i+6)){
  code.push(`do local p=game:GetService(${quote(f.parts[0])})`);
  for(const part of f.parts.slice(1,-1))code.push(`p=folder(p,${quote(part)})`);
  code.push(`local old=p:FindFirstChild(${quote(f.parts.at(-1))});if old then assert(old.ClassName==${quote(f.cls)},"Class mismatch");old:Destroy() end;local s=Instance.new(${quote(f.cls)});s.Name=${quote(f.parts.at(-1))};s.Source=${quote(f.source)};s.Parent=p;end`);
 }
 code.push('return "Synced source batch"');
 callStudio(studio,'execute_luau',{datamodel_type:'Edit',code:code.join('\n')});
 console.log(`Synced ${Math.min(i+6,files.length)}/${files.length}`);
}
// Source is authoritative for the static scene as well as scripts.
const hex=readFileSync(path.join(gameRoot,'assets/world/Lobby.rbxm')).toString('hex');
callStudio(studio,'execute_luau',{datamodel_type:'Edit',code:`
assert(game.PlaceId==0,"Refusing nonlocal place")
local hex=${quote(hex)};local bytes=buffer.create(#hex/2)
for i=1,#hex,2 do buffer.writeu8(bytes,(i-1)/2,tonumber(string.sub(hex,i,i+1),16)) end
local models=game:GetService('SerializationService'):DeserializeInstancesAsync(bytes)
assert(#models==1 and models[1].Name=='BVSCourt','Invalid authored lobby')
local old=workspace:FindFirstChild('BVSCourt');if old then old:Destroy() end
models[1].Parent=workspace
local legacy=workspace:FindFirstChild('AuthoredWorld');if legacy and #legacy:GetChildren()==0 then legacy:Destroy() end
for _,name in {'CourtService','LobbyDetailService'} do
 local old=game.ServerScriptService.Server.Services:FindFirstChild(name);if old then old:Destroy() end
end
return 'Synced authored lobby'
`});
const tree=JSON.parse(readFileSync(path.join(gameRoot,'default.project.json'),'utf8')).tree;
const settings=[];
function applySettings(node,expression){
 for(const [key,value] of Object.entries(node.$properties??{})){
  // Technology is serialized by Rojo; the engine does not expose it to scripts.
  if(key==='Technology')continue;
  const lua=Array.isArray(value)?`Color3.new(${value.join(',')})`:JSON.stringify(value);
  settings.push(`${expression}.${key}=${lua}`);
 }
 for(const [key,child] of Object.entries(node).filter(([key])=>!key.startsWith('$'))){
  settings.push(`do local n=${expression}:FindFirstChild(${quote(key)}) or Instance.new(${quote(child.$className)});n.Name=${quote(key)};n.Parent=${expression}`);
  applySettings(child,'n');settings.push('end');
 }
}
applySettings(tree.Lighting,"game:GetService('Lighting')");
applySettings(tree.Workspace.Terrain,"workspace.Terrain");
callStudio(studio,'execute_luau',{datamodel_type:'Edit',code:settings.join('\n')+"\nreturn 'Synced world lighting'"});
writeFileSync(outputFile('sync-manifest.json'),JSON.stringify({studio,files:files.map(f=>({path:f.relative,sha256:createHash('sha256').update(f.source).digest('hex')}))},null,2));
