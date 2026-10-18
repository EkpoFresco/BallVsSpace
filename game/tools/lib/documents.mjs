import fs from 'node:fs';import path from 'node:path';
export const slash=value=>value.replaceAll('\\','/');
export function walk(dir){return fs.readdirSync(dir,{withFileTypes:true}).sort((a,b)=>a.name.localeCompare(b.name)).flatMap(e=>e.isDirectory()?walk(path.join(dir,e.name)):[path.join(dir,e.name)]);}
export function localLink(from,raw,root){
 const clean=raw.replace(/^<|>$/g,'');if(/^(https?:|mailto:|data:|#)/.test(clean))return null;
 const [target,hash]=clean.split('#');if(!target)return null;
 const file=slash(path.relative(root,path.resolve(path.dirname(from),decodeURIComponent(target))));
 return {file,hash:hash?'#'+hash:''};
}
export function links(file,text){
 return (file.endsWith('.html')?[...text.matchAll(/(?:src|href)="([^"]+)"/g)]:[...text.matchAll(/\]\(([^)]+)\)/g)]).map(m=>m[1]);
}
export function rewriteLinks(file,text,fn){
 return file.endsWith('.html')?text.replace(/((?:src|href)=")([^"]+)(")/g,(_,a,p,b)=>a+fn(p)+b):text.replace(/\]\(([^)]+)\)/g,(_,p)=>']('+fn(p)+')');
}
export function checkLinks(root,files){
 const missing=[];let checked=0;
 for(const file of files){for(const raw of links(file,fs.readFileSync(file,'utf8'))){
  const link=localLink(file,raw,root);if(!link)continue;checked++;
  if(link.file.startsWith('../')||!fs.existsSync(path.join(root,link.file)))missing.push({file:slash(path.relative(root,file)),link:raw});
 }}return {checked,missing};
}
