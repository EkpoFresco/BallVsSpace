// Project-local MCP client. Uses the installed Studio stdio transport and discovered schemas.
import { spawn } from 'node:child_process';
import { createInterface } from 'node:readline';
import { readFileSync, writeFileSync, mkdirSync, readdirSync, existsSync, statSync } from 'node:fs';
import path from 'node:path';
// Re-audit this machine each run. Never carry a previous machine's version directory.
const versions=path.join(process.env.LOCALAPPDATA || '', 'Roblox', 'Versions');
const candidates=existsSync(versions)?readdirSync(versions).map(n=>path.join(versions,n,'StudioMCP.exe')).filter(existsSync):[];
candidates.sort((a,b)=>statSync(b).mtimeMs-statSync(a).mtimeMs);
const exe = process.env.BVS_STUDIO_MCP || candidates[0];
if (!exe) throw Error('StudioMCP.exe not found. Enable Studio MCP, or set BVS_STUDIO_MCP to its verified local executable.');
const child = spawn(exe, [], { windowsHide: true, stdio: ['pipe','pipe','pipe'] });
child.on('error',error=>{console.error(error.message);process.exit(1);});
child.on('exit',code=>{if(pending.size){console.error('Studio MCP exited before replying: '+code);process.exit(1);}});
let id = 0;
const pending = new Map();
child.stderr.on('data', b => process.stderr.write(b));
createInterface({ input: child.stdout }).on('line', line => {
  try { const msg = JSON.parse(line); if (pending.has(msg.id)) { pending.get(msg.id)(msg); pending.delete(msg.id); } } catch { process.stderr.write(line+'\n'); }
});
function request(method, params) {
  const n = ++id;
  return new Promise(resolve => { pending.set(n, resolve); child.stdin.write(JSON.stringify({jsonrpc:'2.0',id:n,method,params})+'\n'); });
}
const timer = setTimeout(() => { child.kill(); console.error('MCP timeout'); process.exit(2); }, 120000);
try {
  const init = await request('initialize', {protocolVersion:'2024-11-05',capabilities:{},clientInfo:{name:'BallVsSpace-local-build',version:'0.1.0'}});
  if (init.error) throw new Error(JSON.stringify(init.error));
  child.stdin.write(JSON.stringify({jsonrpc:'2.0',method:'notifications/initialized'})+'\n');
  const mode = process.argv[2] || 'list';
  const result = mode === 'list' ? await request('tools/list', {}) : await request('tools/call', JSON.parse(readFileSync(process.argv[3], 'utf8').replace(/^\uFEFF/,'')));
  for (const [i,item] of (result.result?.content || []).entries()) {
    if (item.type === 'image' && item.data) {
      const ext=item.mimeType==='image/jpeg'?'jpg':'png';
      const file=(process.argv[4] || 'test-evidence/capture.json').replace(/\.json$/,`-${i}.${ext}`);
      mkdirSync(path.dirname(file),{recursive:true});
      writeFileSync(file,Buffer.from(item.data,'base64'));
      delete item.data; item.savedFile=file;
    }
  }
  const output = JSON.stringify(result,null,2);
  if (process.argv[4]) { mkdirSync(path.dirname(process.argv[4]),{recursive:true}); writeFileSync(process.argv[4],output); }
  console.log(output.length>14000 && process.argv[4] ? JSON.stringify({saved:process.argv[4],isError:result.result?.isError,characters:output.length}) : output);
  if (result.error || result.result?.isError) process.exitCode=1;
} finally { clearTimeout(timer); child.kill(); }
