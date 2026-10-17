import {readFileSync,writeFileSync} from 'node:fs';
import {spawnSync} from 'node:child_process';
const studio=process.argv[2];if(!studio)throw Error('Explicit Studio ID required');
const fixture=readFileSync('tools/mirrored-fixtures.luau','utf8').replace('if seed%5==0 then task.wait() end','game:SetAttribute("BVSMirrorPairs",seed); task.wait()');
const code=`assert(game.PlaceId==0,"Local only");game:SetAttribute("BVSMirrorResult",nil);game:SetAttribute("BVSMirrorError",nil);game:SetAttribute("BVSMirrorPairs",0);task.spawn(function()local ok,result=pcall(function()\n${fixture}\nend);if ok then game:SetAttribute("BVSMirrorResult",game:GetService("HttpService"):JSONEncode(result)) else game:SetAttribute("BVSMirrorError",tostring(result)) end end);return {started=true,pairs=200}`;
const request='tools/review-mirror-request.json';writeFileSync(request,JSON.stringify({name:'execute_luau',arguments:{studio_id:studio,datamodel_type:'Edit',code}}));
const r=spawnSync(process.execPath,['tools/studio-mcp.mjs','call',request,'test-evidence/review-mirrored-start.json'],{encoding:'utf8',windowsHide:true});console.log(r.stdout);if(r.status)throw Error(r.stderr);
