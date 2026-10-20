import {readFileSync,writeFileSync} from 'node:fs';
import {gameRoot,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2],prefix=process.argv[3]||'scale-review';
if(!studio)throw Error('Explicit verified Studio ID required');
process.chdir(gameRoot);const rpc=createQa(studio,prefix);
const run=(code,label)=>rpc('execute_luau',{datamodel_type:'Client',code},label);
const source=readFileSync('tools/qa/fixtures/scale-review.luau','utf8');
run(`local old=game.Players.LocalPlayer.PlayerScripts:FindFirstChild('QAScaleReview');if old then require(old).destroy();old:Destroy() end;local m=Instance.new('ModuleScript');m.Name='QAScaleReview';m.Source=${JSON.stringify(source)};m.Parent=game.Players.LocalPlayer.PlayerScripts;require(m);return true`,'install');
const devices=[['small-window','average_laptop',568,320],['iphone7','iphone_7'],['android','samsung_galaxy_a06'],['notched-phone','iphone_17_pro'],['tablet','ipad_6th_generation'],['compact-desktop','average_laptop',800,600],['mid-desktop','average_laptop',900,650],['hd720','hd_720',1280,720],['hd1080','hd_1080',1920,1080],['ultrawide','average_laptop',2560,1080],['small-return','average_laptop',568,320]];
const results=[];
for(const [name,id,width,height] of devices){
 results.push({device:name,...run(`local s=game:GetService('StudioDeviceSimulatorService');s:SetDeviceAsync(${JSON.stringify(id)});${width?`s:SetResolutionAsync(${width},${height});`:`s:SetOrientationAsync(Enum.ScreenOrientation.LandscapeLeft);`}task.wait(.3);return require(game.Players.LocalPlayer.PlayerScripts.QAScaleReview).all()`,'measure-'+name)});
}
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({scope:'Real engine layouts at emulated resolutions with isolated UI states; separate live-flow receipts validate input/gameplay.',results},null,2));
const issues=results.flatMap(d=>Object.values(d.rows).flatMap(r=>Object.values(r.issues)));
console.log('Scale issues',issues.length);
if(issues.length)process.exitCode=1;
console.log('Scale review saved',outputFile(prefix+'-result.json'));
