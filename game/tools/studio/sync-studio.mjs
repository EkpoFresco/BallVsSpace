import {writeFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {sourceInventory,luauString as quote,outputFile} from '../lib/project.mjs';
import {callStudio} from './client.mjs';
const studio=process.argv[2];if(!studio)throw Error('Explicit verified local Studio ID required');
const files=sourceInventory();
for(let i=0;i<files.length;i+=6){
 const code=['assert(game.PlaceId==0,"Refusing nonlocal place")','local function folder(p,n) local f=p:FindFirstChild(n);if not f then f=Instance.new("Folder");f.Name=n;f.Parent=p end;return f end','folder(game:GetService("ReplicatedStorage"),"Art");folder(game:GetService("Workspace"),"AuthoredWorld");workspace.StreamingEnabled=false;workspace.Gravity=196.2;game:GetService("StarterGui").ScreenOrientation=Enum.ScreenOrientation.LandscapeSensor'];
 for(const f of files.slice(i,i+6)){
  code.push(`do local p=game:GetService(${quote(f.parts[0])})`);
  for(const part of f.parts.slice(1,-1))code.push(`p=folder(p,${quote(part)})`);
  code.push(`local old=p:FindFirstChild(${quote(f.parts.at(-1))});if old then assert(old.ClassName==${quote(f.cls)},"Class mismatch");old:Destroy() end;local s=Instance.new(${quote(f.cls)});s.Name=${quote(f.parts.at(-1))};s.Source=${quote(f.source)};s.Parent=p;end`);
 }
 code.push('return "Synced source batch"');
 callStudio(studio,'execute_luau',{datamodel_type:'Edit',code:code.join('\n')});
 console.log(`Synced ${Math.min(i+6,files.length)}/${files.length}`);
}
writeFileSync(outputFile('sync-manifest.json'),JSON.stringify({studio,files:files.map(f=>({path:f.relative,sha256:createHash('sha256').update(f.source).digest('hex')}))},null,2));
