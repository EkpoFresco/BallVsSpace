import {writeFileSync,readFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
const studio=process.argv[2], mode=process.argv[3], label=process.argv[4]||mode;
if(!studio)throw Error('Explicit Studio ID required');
function call(name,args,suffix){
 const file='tools/replica-request.json';writeFileSync(file,JSON.stringify({name,arguments:{studio_id:studio,...args}}));
 const out=`test-evidence/replica-${suffix}.json`;
 const r=spawnSync(process.execPath,['tools/studio-mcp.mjs','call',file,out],{encoding:'utf8',windowsHide:true});
 if(r.status)throw Error(r.stdout+r.stderr); console.log(suffix,r.stdout.slice(0,2200));
 return JSON.parse(readFileSync(out,'utf8'));
}
if(mode==='start'||mode==='stop')call('start_stop_play',{is_start:mode==='start'},label);
else if(mode==='capture')call('screen_capture',{capture_id:label},label);
else if(mode==='console')call('get_console_output',{},label);
else if(mode==='code')call('execute_luau',{datamodel_type:process.argv[5]||'Client',code:readFileSync(process.argv[6],'utf8')},label);
else if(mode==='click')call('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',instance_path:process.argv[5]}]},label);
else throw Error('Unknown mode');
