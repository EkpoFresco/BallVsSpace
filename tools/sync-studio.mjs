import { readFileSync, readdirSync, writeFileSync, mkdirSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { createHash } from 'node:crypto';
import path from 'node:path';
const root=path.resolve(import.meta.dirname,'..');
const studio=process.argv[2];
if (!studio) throw Error('Explicit verified Studio id required');
const quote=s=>'[====['+s+']====]';
const files=[];
function scan(dir,parts){for(const d of readdirSync(dir,{withFileTypes:true})){if(d.isDirectory()) scan(path.join(dir,d.name),[...parts,d.name]);else if(d.name.endsWith('.luau')){const cls=d.name.endsWith('.server.luau')?'Script':d.name.endsWith('.client.luau')?'LocalScript':'ModuleScript';files.push({file:path.join(dir,d.name),parts:[...parts,d.name.replace(/\.(server|client)\.luau$|\.luau$/,'')],cls});}}}
scan(path.join(root,'src/shared'),['ReplicatedStorage','Shared']);scan(path.join(root,'src/server'),['ServerScriptService','Server']);scan(path.join(root,'src/client'),['StarterPlayer','StarterPlayerScripts','Client']);
const manifest=[];
for(let i=0;i<files.length;i+=6){
 const lines=['assert(game.PlaceId==0,"Refusing nonlocal place")','local function folder(parent,name) local f=parent:FindFirstChild(name);if not f then f=Instance.new("Folder");f.Name=name;f.Parent=parent end;return f end','folder(game:GetService("ReplicatedStorage"),"Art");folder(game:GetService("Workspace"),"AuthoredWorld");game:GetService("Workspace").StreamingEnabled=false;game:GetService("Workspace").Gravity=196.2'];
 for(const f of files.slice(i,i+6)){const source=readFileSync(f.file,'utf8');manifest.push({path:path.relative(root,f.file),sha256:createHash('sha256').update(source).digest('hex')});lines.push(`do local p=game:GetService(${quote(f.parts[0])})`);for(const part of f.parts.slice(1,-1)) lines.push(`p=folder(p,${quote(part)})`);lines.push(`local old=p:FindFirstChild(${quote(f.parts.at(-1))});if old then assert(old.ClassName==${quote(f.cls)},"Class mismatch");old:Destroy() end;local s=Instance.new(${quote(f.cls)});s.Name=${quote(f.parts.at(-1))};s.Source=${quote(source)};s.Parent=p;end`);}
 lines.push('return "Synced source batch"');
 const req=path.join(root,'tools/request.json');writeFileSync(req,JSON.stringify({name:'execute_luau',arguments:{studio_id:studio,datamodel_type:'Edit',code:lines.join('\n')}}));
 const out=spawnSync(process.execPath,[path.join(root,'tools/studio-mcp.mjs'),'call',req],{encoding:'utf8',windowsHide:true});
 if(out.status!==0 || out.stdout.includes('"isError": true')) throw Error(out.stdout+out.stderr);
 console.log(`Synced ${Math.min(i+6,files.length)}/${files.length}`);
}
writeFileSync(path.join(root,'test-evidence/sync-manifest.json'),JSON.stringify({studio,files:manifest},null,2));
