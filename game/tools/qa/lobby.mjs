import {readFileSync,writeFileSync} from 'node:fs';
import {gameRoot,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2],prefix=process.argv[3]||'lobby';
if(!studio)throw Error('Explicit verified Studio ID required');
process.chdir(gameRoot);
const rpc=createQa(studio,prefix);
const code=(value,label)=>rpc('execute_luau',{datamodel_type:'Client',code:value},label);
const capture=label=>rpc('screen_capture',{capture_id:label},label);
code(`local g=game:GetService('Players').LocalPlayer.PlayerGui.BallVsSpace;local deadline=os.clock()+16;repeat task.wait(.1) until g:GetAttribute('Phase')=='Lobby' or os.clock()>deadline;assert(g:GetAttribute('Phase')=='Lobby');return true`,'lobby');
for(const action of ['Store','Inventory','Play']){
 // Moving the character is test setup. Interaction uses normal keyboard input and the live prompt.
 code(`local p=game:GetService('Players').LocalPlayer;local target;for _,v in workspace.BVSCourt:GetDescendants() do if v:IsA('ProximityPrompt') and v:GetAttribute('BVSAction')=='${action}' then target=v;break end end;assert(target and p.Character);p.Character:PivotTo(CFrame.new(target.Parent.Position+Vector3.new(0,3,7)));task.wait(.8);return target:GetFullName()`,'approach-'+action);
 capture('prompt-'+action);
 rpc('user_keyboard_input',{datamodel_type:'Client',actions:[{action:'keyPress',key_code:'E'}]},'press-'+action);
 code(`local r=game:GetService('Players').LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas;local deadline=os.clock()+3;repeat task.wait(.1) until r.Panels['${action}'].Visible or os.clock()>deadline;assert(r.Panels['${action}'].Visible,'Prompt did not open ${action}');return true`,'opened-'+action);
 rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',instance_path:'LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.Panels.'+action+'.Close'}]},'close-'+action);
}
code(`local p=game:GetService('Players').LocalPlayer;local target;for _,v in workspace.BVSCourt:GetDescendants() do if v:IsA('ProximityPrompt') and v:GetAttribute('BVSAction')=='Practice' then target=v;break end end;assert(target);p.Character:PivotTo(CFrame.new(target.Parent.Position+Vector3.new(0,0,6)));task.wait(.8);return target:GetFullName()`,'approach-Practice');
capture('practice-portal');
rpc('user_keyboard_input',{datamodel_type:'Client',actions:[{action:'keyPress',key_code:'E'}]},'press-Practice');
code(`local g=game:GetService('Players').LocalPlayer.PlayerGui.BallVsSpace;local deadline=os.clock()+10;repeat task.wait(.1) until g:GetAttribute('Phase')=='Draft' or os.clock()>deadline;assert(g:GetAttribute('Phase')=='Draft');return true`,'practice-started');
writeFileSync(outputFile(prefix+'-result.json'),JSON.stringify({store:true,inventory:true,duelSelection:true,practicePortal:true,input:'MCP keyboard E after character placement',teleportedForSetup:true},null,2));
