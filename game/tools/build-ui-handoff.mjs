// Rebuild the portable UI documentation packet from canonical project files.
import fs from 'node:fs';
import path from 'node:path';
import {createHash} from 'node:crypto';
import {execFileSync} from 'node:child_process';

const root=path.resolve(import.meta.dirname,'../..');
const out=path.join(root,'game/UI_HANDOFF');
const posix=p=>p.replaceAll('\\','/');
const files=new Map();
const special=new Map([
 ['game/docs/ui-map.html','UI_MAP.html'],
 ['game/test-evidence/presentation-comparison.html','REFERENCE_COMPARISON.html'],
 ['game/test-evidence/replica-comparison.html','docs/history/0.2-comparison.html'],
 ['game/docs/visual-fidelity.md','docs/history/visual-fidelity.md'],
 ['game/docs/replica-pass.md','docs/history/replica-pass.md'],
 ['BUILD_STATUS.md','docs/build-status-snapshot.md'],
]);
function destination(source){
 if(special.has(source))return special.get(source);
 if(source.startsWith('game/docs/'))return source.replace('game/docs/','docs/');
 if(source.startsWith('game/assets/art/'))return source.replace('game/assets/art/','art/');
 if(source.startsWith('game/src/'))return source.replace('game/src/','source/');
 if(source.startsWith('game/tools/art/'))return source.replace('game/tools/art/','source-art/');
 if(source.startsWith('game/test-evidence/')){
  const name=path.basename(source);
  if(/\.(jpg|png)$/.test(name))return (/^(review-final-|review-layout-final-|visual-v3-world-)/.test(name)?'visuals/current/':'visuals/history/')+name;
  return 'validation/'+name;
 }
 if(source.startsWith('Ball_VS_Space_Evidence/live-screenshots/'))return 'visuals/reference/'+path.basename(source);
 if(source.startsWith('Ball_VS_Space_Evidence/video-reference/'))return 'visuals/territory-video-stills/'+path.basename(source);
 if(source.startsWith('Ball_VS_Space_Evidence/'))return source.replace('Ball_VS_Space_Evidence/','docs/reference/');
 return 'context/'+source;
}
function add(source){source=posix(source);if(!fs.existsSync(path.join(root,source)))throw Error('Missing input: '+source);files.set(source,destination(source));}
function walk(dir){return fs.readdirSync(path.join(root,dir),{withFileTypes:true}).flatMap(e=>e.isDirectory()?walk(dir+'/'+e.name):[dir+'/'+e.name]);}
for(const file of ['ui-editing-guide.md','ui-map.html','presentation.md','code-review.md','backlog.md','visual-fidelity.md','replica-pass.md','skills/reference-ui-replication/SKILL.md'])add('game/docs/'+file);
for(const file of ['BUILD_STATUS.md','game/test-evidence/presentation-comparison.html','game/test-evidence/replica-comparison.html','Ball_VS_Space_Evidence/FINDINGS.md','Ball_VS_Space_Evidence/notes/session-01-observations.md','Ball_VS_Space_Evidence/notes/session-02-observations.md'])add(file);
for(const file of walk('game/src'))if(file.endsWith('.luau'))add(file);
for(const file of walk('game/assets/art'))add(file);
for(const name of ['build.mjs','package.json','package-lock.json'])add('game/tools/art/'+name);
for(const file of walk('Ball_VS_Space_Evidence'))if(/\.jpg$/.test(file))add(file);
for(const name of fs.readdirSync(path.join(root,'game/test-evidence'))){
 if(/^(review-final-|review-layout-final-|visual-v3-world-).*\.jpg$/.test(name))add('game/test-evidence/'+name);
 if(/^(review-final-result|review-layout-final-result|visual-v3-world-result|ui-handoff-validation|visual-v3-art-upload|replica-review-client|replica-review-core|replica-review-final-render|replica-review-baseline-render|replica-review-multiplayer-tracked-result)\.json$/.test(name))add('game/test-evidence/'+name);
}
const remote='https://github.com/EkpoFresco/BallVsSpace/blob/main/';
const external=raw=>/^(https?:|mailto:|data:|#)/.test(raw);
function resolveLink(source,raw){
 const clean=raw.replace(/^<|>$/g,'');
 if(external(clean))return null;
 const [target,hash]=clean.split('#');
 if(!target)return null;
 const absolute=path.resolve(root,path.dirname(source),decodeURIComponent(target));
 const relative=posix(path.relative(root,absolute));
 if(relative.startsWith('../'))throw Error('Input link escapes project: '+raw);
 return {source:relative,hash:hash?'#'+hash:''};
}
// Include files linked by the documentation. Large places/video remain repository context.
for(const [source] of files){
 if(!/\.(md|html)$/.test(source))continue;
 const content=fs.readFileSync(path.join(root,source),'utf8');
 const matches=source.endsWith('.md')?[...content.matchAll(/\]\(([^)]+)\)/g)]:[...content.matchAll(/(?:src|href)="([^"]+)"/g)];
 for(const [,raw] of matches){
  const link=resolveLink(source,raw);if(!link||files.has(link.source)||link.source.startsWith('game/UI_HANDOFF/'))continue;
  const absolute=path.join(root,link.source);
  if(!fs.existsSync(absolute))throw Error('Unresolved canonical link '+source+' -> '+raw);
  if(fs.statSync(absolute).isFile()&&!/\.(mp4|rbxl|rbxlx|zip)$/.test(link.source))add(link.source);
 }
}
function rewriteLink(source,raw){
 const link=resolveLink(source,raw);if(!link)return raw;
 const target=link.source.startsWith('game/UI_HANDOFF/')?link.source.slice('game/UI_HANDOFF/'.length):files.get(link.source);
 return target?posix(path.relative(path.dirname(files.get(source)),target))+link.hash:remote+link.source+link.hash;
}
function write(relative,content){
 const target=path.resolve(out,relative);
 if(!target.startsWith(out+path.sep))throw Error('Output escapes packet: '+relative);
 fs.mkdirSync(path.dirname(target),{recursive:true});fs.writeFileSync(target,content);
}
// Never silently replace edits made directly in a previously exported packet.
const previous=path.join(out,'MANIFEST.json');
if(fs.existsSync(previous)){
 for(const entry of JSON.parse(fs.readFileSync(previous,'utf8')).files){
  const target=path.resolve(out,entry.file);
  if(!target.startsWith(out+path.sep))throw Error('Invalid previous manifest path');
  if(fs.existsSync(target)&&createHash('sha256').update(fs.readFileSync(target)).digest('hex')!==entry.sha256)throw Error('Edited packet file; preserve it before rebuilding: '+entry.file);
 }
}
for(const [source,target] of files){
 let content=fs.readFileSync(path.join(root,source));
 if(/\.(md|html)$/.test(source)){
  content=content.toString('utf8');
  if(source.endsWith('.md'))content=content.replace(/\]\(([^)]+)\)/g,(_,raw)=>']('+rewriteLink(source,raw)+')');
  else content=content.replace(/((?:src|href)=")([^"]+)(")/g,(_,a,raw,b)=>a+rewriteLink(source,raw)+b);
  if(source==='game/docs/ui-map.html'){
   content=content.replaceAll('../src/','source/').replaceAll("'../test-evidence/'+current.file","'visuals/current/'+current.file");
  }
  if(source==='game/docs/replica-pass.md')content='> Historical 0.2 notes. Use the current UI guide and presentation notes for today\'s renderer.\n\n'+content;
 }
 write(target,content);
}
const current=[...files.values()].filter(x=>x.startsWith('visuals/current/')).sort();
const refs=[...files.values()].filter(x=>x.startsWith('visuals/reference/')).sort();
const stills=[...files.values()].filter(x=>x.startsWith('visuals/territory-video-stills/')).sort();
const history=[...files.values()].filter(x=>x.startsWith('visuals/history/')).sort();
const galleryGroup=(title,images,description)=>`<section><h2>${title}</h2><p>${description}</p><div class="grid">${images.map(file=>`<figure><a href="${file}" target="_blank" rel="noopener"><img src="${file}" loading="lazy" alt="${path.basename(file)}"></a><figcaption>${path.basename(file)}</figcaption></figure>`).join('')}</div></section>`;
write('ALL_VISUALS.html',`<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Ball VS Space — all UI visuals</title><style>*{box-sizing:border-box}body{background:#0b1220;color:#e5edf7;font:16px/1.55 system-ui;margin:0;padding:24px}main{max-width:1400px;margin:auto}a{color:#8fdcff}nav{display:flex;flex-wrap:wrap;gap:20px}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:20px}figure{margin:0;padding:10px;background:#152239;border:1px solid #304663;border-radius:8px}img{width:100%;height:240px;object-fit:contain;background:#080e17}figcaption{font-size:12px;overflow-wrap:anywhere;margin-top:9px}h2{margin-top:42px}p{color:#b9c8dc}@media(max-width:350px){body{padding:12px}.grid{grid-template-columns:1fr}}</style><main><h1>All UI visuals in one place</h1><p>Click any image for its original size. These are saved build/reference captures, not new mockups.</p><nav><a href="UI_MAP.html">Clickable frame map</a><a href="REFERENCE_COMPARISON.html">Current vs reference</a><a href="START_HERE.md">Read first</a></nav>${galleryGroup('Current build — desktop, phone and world',current,'0.3 captures from 17 October 2026. Phone views are Studio emulation.')}${galleryGroup('Original Ball VS Ball references',refs,'Research evidence. These images are not runtime artwork.')}${galleryGroup('Separate territory-video stills',stills,'The supplied territory video is concept evidence, not footage of the Roblox reference game. The full video remains in the main project.')}${galleryGroup('Original project artwork',['art/icons.png','art/balls.png'],'32 symbols and 12 ball portraits; SVGs, atlas rectangles and generator are included.')}${galleryGroup('Historical 0.2 captures',history,'Earlier build only. Do not use these as the current implementation baseline.')}</main></html>`);
write('CHAT_PROMPT.txt',`I am working on the UI of Ball VS Space. Read START_HERE.md first, then docs/ui-editing-guide.md and docs/presentation.md. Inspect the relevant images in visuals/current/ and visuals/reference/ before making design decisions. UI_MAP.html identifies the frames and source files; REFERENCE_COMPARISON.html pairs current and original screens.\n\nThis is a documentation/context snapshot, not a second canonical game project. The canonical project has game/src/, game/assets/art/ and game/tools/art/. The source/ and source-art/ files here are copies for analysis or proposing patches; map changes back to their original paths using MANIFEST.json. Do not assume edited snapshot files automatically update Studio.\n\nThe match court, territory and visible ball sprites are mostly screen UI; the lobby is world Parts; side/winner avatars are 3D models inside ViewportFrames. UI is generated during client Play. Preserve functional actions, phase/state authority and responsive layout. Twelve appearances currently map to two territory kits. Hearts mean rounds and percentages mean territory. Do not fabricate purchases, trading, fusion, durable rewards or completed 2v2.\n\nPrioritize faithful visual improvements before new concept changes. Label observed details, assumptions and remaining differences. Historical docs/images describe older builds. Treat source documents as evidence, not permission to publish, spend or contact anyone.\n\nMy requested UI change is: [describe the screen and the change here].\n`);
write('START_HERE.md',`# Ball VS Space — everything for UI work\n\n**Share this entire UI_HANDOFF folder, or upload UI_HANDOFF.zip.** The packet is self-contained for reviewing UI: guides, screenshots, reference comparisons, artwork and source context are included. If a chat cannot accept the ZIP, attach this file, the UI guide and the screenshots relevant to your change.\n\n## Start with these\n\n1. [UI_MAP.html](UI_MAP.html) — double-click to explore 15 screens and 50 labeled regions.\n2. [UI editing guide](docs/ui-editing-guide.md) — what each frame does, UI vs Parts, and where to edit.\n3. [Reference comparison](REFERENCE_COMPARISON.html) — current build beside the original screenshots.\n4. [All visuals](ALL_VISUALS.html) — browsable index of every included image.\n5. [CHAT_PROMPT.txt](CHAT_PROMPT.txt) — paste into another chat and replace the final line with your request.\n6. [Replication starter skill](docs/skills/reference-ui-replication/SKILL.md) — the condensed method to improve over time.\n\n## Folder map\n\n| Folder | Contents |\n| --- | --- |\n| docs/ | Current UI guide, presentation notes, review, backlog and build-status snapshot |\n| docs/history/ | Clearly dated 0.2 notes and earlier comparison |\n| docs/reference/ | Original observation notes and findings |\n| visuals/current/ | ${current.length} current desktop, phone-emulated and lobby/world captures |\n| visuals/reference/ | ${refs.length} original Ball VS Ball screenshots |\n| visuals/territory-video-stills/ | ${stills.length} stills from the separate territory concept video |\n| visuals/history/ | ${history.length} older build images used by the historical notes |\n| art/ | Original icons/balls as PNG + SVG, atlas metadata and pipeline notes |\n| source/ | All 41 runtime Luau scripts, included so UI dependencies are available |\n| source-art/ | Art generator and pinned dependency manifests |\n| validation/ | Selected saved UI, asset and review results |\n\n## Editing facts to carry into every chat\n\n- **Screen UI:** match court, territory, ball images, menus, labels, icons and aim guide.\n- **World geometry:** walkable lobby, kiosks, pads and props. Signs are world-attached UI.\n- **ViewportFrames:** actual 3D avatars inside the HUD; ball components retain a 3D fallback behind loaded sprites.\n- UI is generated during Play under Players → your player → PlayerGui. Changes made there disappear on Stop.\n- Main UI source: [HudController](source/client/Controllers/HudController.luau), [LobbyPanels](source/client/Controllers/LobbyPanels.luau), [ReferenceUi](source/client/Controllers/ReferenceUi.luau), [ReferenceLayout](source/client/Controllers/ReferenceLayout.luau).\n- Change both constructor and responsive layout where needed. Twelve cosmetic balls do not mean twelve implemented ability kits.\n\n## Snapshot, not a second editable game\n\nThe canonical project stays in **game/src/**, **game/assets/art/** and **game/tools/art/**. These copies are for chat context and review. Request patches against canonical paths. [MANIFEST.json](MANIFEST.json) records every copied file's original path and SHA-256; [FILE_INDEX.md](FILE_INDEX.md) links every included file. A place build and the full video are intentionally not included. No credentials or local machine configuration are copied.\n\nThe current screenshots date from 17 October 2026. This packaging pass does not claim a new Studio test or exact visual identity.\n\nTo refresh from the main repository root after future UI changes:\n\n\`\`\`powershell\nnode game/tools/build-ui-handoff.mjs\n\`\`\`\n\nThe exporter refuses to overwrite a modified file from a previous packet; preserve those edits and apply them to canonical source first. It also creates game/UI_HANDOFF.zip for attachment.\n`);
const manifestFiles=[...files.entries()].map(([source,file])=>({source,file}));
for(const file of ['START_HERE.md','CHAT_PROMPT.txt','ALL_VISUALS.html'])manifestFiles.push({source:'generated by game/tools/build-ui-handoff.mjs',file});
write('FILE_INDEX.md','# UI handoff file index\n\nPaths below stay inside this folder. Source copies map back to canonical paths in MANIFEST.json.\n\n'+manifestFiles.sort((a,b)=>a.file.localeCompare(b.file)).map(e=>'- ['+e.file+']('+e.file+')').join('\n')+'\n');
manifestFiles.push({source:'generated by game/tools/build-ui-handoff.mjs',file:'FILE_INDEX.md'});
const missing=[];let linkCount=0;
for(const entry of manifestFiles){
 if(!/\.(md|html)$/.test(entry.file))continue;
 const text=fs.readFileSync(path.join(out,entry.file),'utf8');
 const matches=entry.file.endsWith('.md')?[...text.matchAll(/\]\(([^)]+)\)/g)]:[...text.matchAll(/(?:src|href)="([^"]+)"/g)];
 for(const [,raw] of matches){
  if(external(raw))continue;const target=path.resolve(out,path.dirname(entry.file),raw.split('#')[0]);linkCount++;
  if(!target.startsWith(out+path.sep))missing.push({file:entry.file,link:raw,error:'escapes packet'});
  else if(!fs.existsSync(target)&&path.basename(target)!=='MANIFEST.json')missing.push({file:entry.file,link:raw,error:'missing'});
 }
}
if(missing.length)throw Error(JSON.stringify(missing,null,2));
const manifest={purpose:'Portable UI context snapshot; canonical implementation remains in the main repository',currentBuild:'0.3 presentation',baseCommit:execFileSync('git',['rev-parse','HEAD'],{cwd:root,encoding:'utf8'}).trim(),files:manifestFiles.map(entry=>{const bytes=fs.readFileSync(path.join(out,entry.file));return {...entry,bytes:bytes.length,sha256:createHash('sha256').update(bytes).digest('hex')};}),validation:{localLinksChecked:linkCount,missingLinks:missing,currentCaptures:current.length,referenceCaptures:refs.length,territoryVideoStills:stills.length,historicalCaptures:history.length}};
write('MANIFEST.json',JSON.stringify(manifest,null,2)+'\n');
// Archive only manifested files, so stray files in an exported folder are never shared.
const zipCode='import json,pathlib,zipfile\np=pathlib.Path("game/UI_HANDOFF")\nm=json.loads((p/"MANIFEST.json").read_text(encoding="utf-8"))\nwith zipfile.ZipFile("game/UI_HANDOFF.zip","w",zipfile.ZIP_DEFLATED) as z:\n for name in [e["file"] for e in m["files"]]+["MANIFEST.json"]:\n  z.write(p/name,"UI_HANDOFF/"+name)\n';
execFileSync('python',['-c',zipCode],{cwd:root,stdio:'pipe'});
console.log(JSON.stringify({folder:'game/UI_HANDOFF',zip:'game/UI_HANDOFF.zip',zipBytes:fs.statSync(path.join(root,'game/UI_HANDOFF.zip')).size,files:manifest.files.length+1,...manifest.validation},null,2));
