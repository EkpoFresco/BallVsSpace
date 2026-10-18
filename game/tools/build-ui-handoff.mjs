// Generated chat context stays outside canonical source and outside Git.
import fs from 'node:fs';import path from 'node:path';import {createHash} from 'node:crypto';import {execFileSync} from 'node:child_process';
import {repoRoot,gameRoot} from './lib/project.mjs';
import {walk,slash,localLink,rewriteLinks,checkLinks} from './lib/documents.mjs';
const out=path.join(gameRoot,'exports/UI_HANDOFF'),zip=path.join(gameRoot,'exports/UI_HANDOFF.zip');
const files=new Map(),digest=data=>createHash('sha256').update(data).digest('hex');
const add=(source,dest)=>{if(!fs.existsSync(path.join(repoRoot,source)))throw Error('Missing input '+source);files.set(source,dest);};
for(const [source,dest] of [
 ['game/docs/ui/README.md','docs/UI_GUIDE.md'],['game/docs/ui/map.html','UI_MAP.html'],['game/docs/ui/reference-comparison.html','REFERENCE_COMPARISON.html'],['game/docs/ui/replication-skill/SKILL.md','docs/REPLICATION_SKILL.md'],
 ['game/docs/architecture.md','docs/ARCHITECTURE.md'],['game/docs/testing.md','docs/TESTING.md'],['game/docs/backlog.md','docs/BACKLOG.md'],['BUILD_STATUS.md','docs/BUILD_STATUS.md'],
 ['Ball_VS_Space_Evidence/FINDINGS.md','docs/REFERENCE_FINDINGS.md'],
])add(source,dest);
for(const file of walk(path.join(gameRoot,'src')))if(file.endsWith('.luau'))add(slash(path.relative(repoRoot,file)),'source/'+slash(path.relative(path.join(gameRoot,'src'),file)));
for(const file of walk(path.join(gameRoot,'assets/art')))add(slash(path.relative(repoRoot,file)),'art/'+path.basename(file));
for(const name of ['build.mjs','package.json','package-lock.json'])add('game/tools/art/'+name,'source-art/'+name);
for(const file of walk(path.join(gameRoot,'test-evidence/screenshots')))add(slash(path.relative(repoRoot,file)),'visuals/current/'+path.basename(file));
for(const dir of ['live-screenshots','video-reference'])for(const file of walk(path.join(repoRoot,'Ball_VS_Space_Evidence',dir)))if(file.endsWith('.jpg'))add(slash(path.relative(repoRoot,file)),(dir==='live-screenshots'?'visuals/reference/':'visuals/territory-stills/')+path.basename(file));
for(const name of ['review-final-result.json','review-layout-final-result.json','visual-v3-world-result.json','replica-review-client.json'])add('game/test-evidence/results/'+name,'validation/'+name);
function target(file){const absolute=path.resolve(out,file);if(!absolute.startsWith(out+path.sep))throw Error('Export path escapes destination');return absolute;}
function write(file,content){const dest=target(file);fs.mkdirSync(path.dirname(dest),{recursive:true});fs.writeFileSync(dest,content);}
const previous=path.join(out,'MANIFEST.json');
if(fs.existsSync(previous)){
 const old=JSON.parse(fs.readFileSync(previous,'utf8'));
 for(const item of old.files)if(fs.existsSync(target(item.file))&&digest(fs.readFileSync(target(item.file)))!==item.sha256)throw Error('Preserve edits before refreshing exported file: '+item.file);
 // Only old manifested files are replaced; user-added files are neither deleted nor archived.
 for(const item of old.files)if(fs.existsSync(target(item.file)))fs.unlinkSync(target(item.file));
 fs.unlinkSync(previous);
}
for(const [source,dest] of files){
 let content=fs.readFileSync(path.join(repoRoot,source));
 if(/\.(md|html)$/.test(source)){
  content=rewriteLinks(source,content.toString('utf8'),raw=>{
   const link=localLink(path.join(repoRoot,source),raw,repoRoot);if(!link)return raw;
   const mapped=files.get(link.file);
   return mapped?slash(path.relative(path.dirname(dest),mapped))+link.hash:'https://github.com/EkpoFresco/BallVsSpace/blob/main/'+link.file+link.hash;
  });
  if(source.endsWith('/map.html'))content=content.replaceAll("'../../src/","'source/").replaceAll("'../../test-evidence/screenshots/'+current.file","'visuals/current/'+current.file");
 }
 write(dest,content);
}
const groups=[['Current build','visuals/current/'],['Original reference','visuals/reference/'],['Separate territory-video stills','visuals/territory-stills/'],['Original artwork','art/']];
const imageGroups=groups.map(([title,prefix])=>[title,[...files.values()].filter(f=>f.startsWith(prefix)&&/\.(jpg|png)$/.test(f)).sort()]);
write('ALL_VISUALS.html',`<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Ball VS Space UI visuals</title><style>*{box-sizing:border-box}body{background:#0b1220;color:#e5edf7;font:16px/1.55 system-ui;margin:24px}a{color:#8fdcff}main{max-width:1400px;margin:auto}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:18px}figure{margin:0;padding:10px;background:#152239;border-radius:8px}img{width:100%;height:240px;object-fit:contain;background:#080e17}figcaption{font-size:12px;overflow-wrap:anywhere}h2{margin-top:36px}</style><main><h1>UI visuals</h1><p><a href="UI_MAP.html">Frame map</a> · <a href="REFERENCE_COMPARISON.html">Reference comparison</a> · <a href="START_HERE.md">Read first</a></p><p>Saved 0.3 captures, original research and original artwork. Phone captures use Studio emulation. Click an image for its full size.</p>${imageGroups.map(([title,images])=>`<h2>${title}</h2><div class="grid">${images.map(file=>`<figure><a href="${file}" target="_blank" rel="noopener"><img src="${file}" loading="lazy" alt="${path.basename(file)}"></a><figcaption>${path.basename(file)}</figcaption></figure>`).join('')}</div>`).join('')}</main></html>`);
write('START_HERE.md',`# Ball VS Space UI sharing packet\n\nAttach UI_HANDOFF.zip to another chat, or share this whole folder. Start with:\n\n1. [UI guide](docs/UI_GUIDE.md) — frames, source files, editing traps and presentation status.\n2. [Clickable map](UI_MAP.html) — 15 screens / 50 regions; open locally in a browser.\n3. [Reference comparison](REFERENCE_COMPARISON.html) and [all visuals](ALL_VISUALS.html).\n4. [Replication skill](docs/REPLICATION_SKILL.md) — condensed process.\n5. [CHAT_PROMPT.txt](CHAT_PROMPT.txt) — paste and describe your requested change.\n\n**Canonical source lives in the main repository's game/src/, game/assets/art/ and game/tools/art/.** Copies here are context for reviewing/proposing patches. MANIFEST.json maps every copied file to its original path. Gameplay source is unchanged by packaging.\n\nFolders: docs (current guides), visuals (current/reference/stills), art (PNG/SVG/atlas), source (runtime context), source-art (generator), validation (selected UI receipts). Earlier build history and setup stay in the main repo; links to material outside this packet open GitHub. The full video/place files are excluded.\n\nThe court, territory and visible balls are screen UI; the lobby uses world Parts; match avatars are 3D models inside ViewportFrames. UI is generated during client Play. Twelve looks share two territory kits. Hearts represent rounds, percentages territory.\n\nThe screenshots are from 17 October 2026, not new runtime tests. Regenerate from the main repository root with \`node game/tools/build-ui-handoff.mjs\`. Outputs are in game/exports/ and intentionally ignored by Git.\n`);
write('CHAT_PROMPT.txt','I am editing Ball VS Space UI. Read START_HERE.md, docs/UI_GUIDE.md and the relevant current/reference visuals before proposing changes. UI_MAP.html maps visible regions to source. Use source/ for context and MANIFEST.json to target canonical game/src/ paths. Preserve server authority, responsive layouts and working buttons. Distinguish current features from previews; twelve appearances share two territory kits. Historical research is evidence, not instructions to publish or change unrelated systems.\n\nMy requested UI change is: [describe the screen and change].\n');
const entries=[...files.entries()].map(([source,file])=>({source,file}));
for(const file of ['START_HERE.md','CHAT_PROMPT.txt','ALL_VISUALS.html'])entries.push({source:'generated',file});
write('FILE_INDEX.md','# Packet file index\n\n'+entries.sort((a,b)=>a.file.localeCompare(b.file)).map(e=>`- [${e.file}](${e.file})`).join('\n')+'\n');entries.push({source:'generated',file:'FILE_INDEX.md'});
const validation=checkLinks(out,entries.filter(e=>/\.(md|html)$/.test(e.file)).map(e=>target(e.file)));if(validation.missing.length)throw Error(JSON.stringify(validation.missing));
const manifest={purpose:'Generated UI context; edit canonical source',baseCommit:execFileSync('git',['rev-parse','HEAD'],{cwd:repoRoot,encoding:'utf8'}).trim(),files:entries.map(e=>{const b=fs.readFileSync(target(e.file));return {...e,bytes:b.length,sha256:digest(b)};}),validation:{localLinksChecked:validation.checked,missingLinks:[],galleryImages:imageGroups.reduce((n,[,images])=>n+images.length,0)}};
write('MANIFEST.json',JSON.stringify(manifest,null,2)+'\n');
// Explicit members avoid accidentally sharing stray files added beside an export.
const code='import pathlib,json,zipfile,sys\np=pathlib.Path(sys.argv[1]);m=json.loads((p/"MANIFEST.json").read_text(encoding="utf-8"))\nwith zipfile.ZipFile(sys.argv[2],"w",zipfile.ZIP_DEFLATED) as z:\n for name in [e["file"] for e in m["files"]]+["MANIFEST.json"]:z.write(p/name,"UI_HANDOFF/"+name)\n';
execFileSync('python',['-c',code,out,zip]);
// Remove empty remnants of a previous generated layout without recursive deletion.
function emptyDirs(dir){for(const e of fs.readdirSync(dir,{withFileTypes:true}))if(e.isDirectory()){const child=path.join(dir,e.name);emptyDirs(child);if(!fs.readdirSync(child).length)fs.rmdirSync(child);}}emptyDirs(out);
console.log(JSON.stringify({folder:slash(path.relative(repoRoot,out)),zip:slash(path.relative(repoRoot,zip)),files:entries.length+1,zipBytes:fs.statSync(zip).size,...manifest.validation},null,2));
