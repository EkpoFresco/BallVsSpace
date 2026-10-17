import {readFileSync,writeFileSync,readdirSync,existsSync} from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
const root=path.resolve(import.meta.dirname,'../..');
const evidence=path.join(root,'Ball_VS_Space_Evidence');
const manifest=JSON.parse(readFileSync(path.join(evidence,'file-integrity.json'),'utf8'));
const mismatches=[];
for(const entry of manifest){
 const file=path.join(evidence,entry.file);
 if(!existsSync(file)||createHash('sha256').update(readFileSync(file)).digest('hex')!==entry.sha256)mismatches.push(entry.file);
}
const docs=['README.md','CONTRIBUTING.md','BUILD_STATUS.md',...readdirSync(path.join(root,'game/docs')).filter(x=>x.endsWith('.md')).map(x=>'game/docs/'+x),'game/test-evidence/presentation-comparison.html','game/test-evidence/replica-comparison.html'];
const missing=[];let checked=0;
for(const name of docs){
 const text=readFileSync(path.join(root,name),'utf8');
 const matches=name.endsWith('.html')?[...text.matchAll(/(?:src|href)="([^"]+)"/g)]:[...text.matchAll(/\]\(([^)]+)\)/g)];
 for(const [,raw] of matches){
  const link=raw.replace(/^<|>$/g,'').split('#')[0];
  if(!link||/^(https?:|mailto:|data:)/.test(link))continue;
  checked++;
  if(!existsSync(path.resolve(root,path.dirname(name),decodeURIComponent(link))))missing.push({file:name,link});
 }
}
const result={referenceFiles:manifest.length,referenceHashMismatches:mismatches,localLinksChecked:checked,missingLinks:missing};
writeFileSync(path.join(root,'game/test-evidence/review-repository-audit.json'),JSON.stringify(result,null,2));
console.log(JSON.stringify(result,null,2));
if(mismatches.length||missing.length)process.exitCode=1;
