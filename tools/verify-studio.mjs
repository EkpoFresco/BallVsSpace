import {readFileSync,readdirSync,writeFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const studio=process.argv[2];
if(!studio)throw Error('Explicit verified Studio ID required');
const quote=s=>'[====['+s+']====]';
const files=[];
function scan(dir,parts){for(const d of readdirSync(dir,{withFileTypes:true})){if(d.isDirectory())scan(path.join(dir,d.name),[...parts,d.name]);else if(d.name.endsWith('.luau'))files.push({file:path.join(dir,d.name),parts:[...parts,d.name.replace(/\.(server|client)\.luau$|\.luau$/,'')]});}}
scan(path.join(root,'src/shared'),['ReplicatedStorage','Shared']);scan(path.join(root,'src/server'),['ServerScriptService','Server']);scan(path.join(root,'src/client'),['StarterPlayer','StarterPlayerScripts','Client']);
const code=['assert(game.PlaceId==0,"Wrong place")'];
for(const f of files){let expr=`game:GetService(${quote(f.parts[0])})`;for(const p of f.parts.slice(1))expr+=`:FindFirstChild(${quote(p)})`;code.push(`assert(${expr}.Source==${quote(readFileSync(f.file,'utf8'))},${quote('Source mismatch: '+f.parts.join('.'))})`);}
code.push(`return {verifiedSourceFiles=${files.length},placeId=game.PlaceId,gameId=game.GameId,streaming=workspace.StreamingEnabled}`);
const req=path.join(root,'tools/verify-source-request.json');writeFileSync(req,JSON.stringify({name:'execute_luau',arguments:{studio_id:studio,datamodel_type:'Edit',code:code.join('\n')}}));
const p=spawnSync(process.execPath,[path.join(root,'tools/studio-mcp.mjs'),'call',req,path.join(root,'test-evidence/source-consistency.json')],{encoding:'utf8',windowsHide:true});
console.log(p.stdout);if(p.status)throw Error(p.stderr||'Source verification failed');
