import {readFileSync} from 'node:fs';
import {callStudio} from '../studio/client.mjs';
import {outputFile} from '../lib/project.mjs';
const fixture=readFileSync(new URL('./fixtures/mirrored.luau',import.meta.url),'utf8').replace('if seed%5==0 then task.wait() end','game:SetAttribute("BVSMirrorPairs",seed);task.wait()');
const code=`assert(game.PlaceId==0,"Local only");game:SetAttribute("BVSMirrorResult",nil);game:SetAttribute("BVSMirrorError",nil);game:SetAttribute("BVSMirrorPairs",0);task.spawn(function()local ok,result=pcall(function()\n${fixture}\nend);if ok then game:SetAttribute("BVSMirrorResult",game:GetService("HttpService"):JSONEncode(result)) else game:SetAttribute("BVSMirrorError",tostring(result)) end end);return {started=true,pairs=200}`;
console.log(callStudio(process.argv[2],'execute_luau',{datamodel_type:'Edit',code},outputFile('mirrored-start.json')));
