import {readFileSync,writeFileSync} from 'node:fs';
import {gameRoot,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2],prefix=process.argv[3]||'ui-flow';
if(!studio)throw Error('Explicit verified Studio ID required');
process.chdir(gameRoot);
const rpc=createQa(studio,prefix);
const code=(value,label)=>rpc('execute_luau',{datamodel_type:'Client',code:value},label);
const click=(path,label)=>rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',instance_path:'LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.'+path}]},label);
const capture=label=>rpc('screen_capture',{capture_id:label},label);
const g='game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace';
function phase(allowed,seconds=15){
 const r=code(`local g=${g};local limit=os.clock()+${seconds};repeat task.wait(.1) until table.find({${allowed.map(x=>JSON.stringify(x)).join(',')}},g:GetAttribute("Phase")) or os.clock()>limit;return g:GetAttribute("Phase")`,'wait-'+allowed.join('-'));
 if(!allowed.includes(r))throw Error('Unexpected phase '+r); return r;
}
function panel(name){code(`local r=${g}.ReferenceCanvas;local untilTime=os.clock()+3;repeat task.wait(.05) until r.Panels[${JSON.stringify(name)}].Visible or os.clock()>untilTime;assert(r.Panels.Visible and r.Panels[${JSON.stringify(name)}].Visible);return true`,'panel-'+name)}
phase(['Lobby']);
const loaded=code(`local p=game:GetService("Players").LocalPlayer.PlayerGui;local deadline=os.clock()+15;local missing,count;repeat missing={};count=0;for _,i in p:GetDescendants() do if i:IsA("ImageLabel") and i:GetAttribute("ArtworkId") then local visible=true;local ancestor=i;while ancestor and ancestor~=p do if ancestor:IsA("GuiObject") and not ancestor.Visible then visible=false;break end;ancestor=ancestor.Parent end;if visible then count+=1;if not i.IsLoaded then table.insert(missing,i:GetFullName()) end end end end;if #missing>0 then task.wait(.2) end until #missing==0 or os.clock()>deadline;assert(#missing==0,table.concat(missing,","));return {authoredImages=count,loaded=true}`, 'assets-loaded');
capture('lobby');
click('Lobby.Inventory','inventory');panel('Inventory');capture('inventory');
click('Panels.Inventory.BallsPage.Grid.Axe','select-axe');click('Panels.Inventory.BallsPage.Details.Equip','equip-axe');
code(`assert(${g}.ReferenceCanvas.Panels.Inventory.BallsPage.Details.Equipped.Text=="Equipped: Axe");return true`,'equip-feedback');
click('Panels.Inventory.Explosions','explosions');capture('explosions');click('Panels.Inventory.Flyers','flyers');capture('flyers');click('Panels.Inventory.Close','close-inventory');
click('Lobby.Store','store');panel('Store');capture('store');click('Panels.Store.Offers.ViewLaser','inspect-laser');panel('Inventory');
code(`assert(${g}.ReferenceCanvas.Panels.Inventory.BallsPage.Details:FindFirstChild("Name").Text=="Laser Ball");return true`,'store-detail');click('Panels.Inventory.Close','close-detail');
for(const [button,name] of [['Rewards','Rewards'],['Lobby.Emotes','Emotes'],['Lobby.Trade','Trade'],['Lobby.Invite','Invite friends'],['Lobby.Mode','Play']]){
 click(button,'open-'+name);panel(name);capture(name.toLowerCase().replaceAll(' ','-'));click('Panels.'+name+'.Close','close-'+name);
}
click('Settings','settings');capture('settings');click('Settings','close-settings');
click('Controls.Left','queue');phase(['Queued']);capture('queue');click('Controls.Primary','cancel');phase(['Lobby']);
click('Controls.Right','practice');
let outcome;
for(let round=1;round<=3;round++){
 const entering=phase(['Draft','MatchResult']);if(entering==='MatchResult')break;
 code(`local r=${g}.ReferenceCanvas;for i=1,2 do local side=r["PlayerSide"..i];local v=side.KitIcon;if side.PlayerFigure:GetAttribute("UserId")~=game:GetService("Players").LocalPlayer.UserId then assert(v.Unknown.Visible and not v.Sprite.Visible,"Opponent draft appearance visible") else assert(v.Sprite.Visible,"Own draft preview missing") end end;return true`,'private-draft-'+round);
 capture('draft-'+round);
 if(round===1){click('Draft.AllBalls','all-balls');capture('collection');click('Collection.Acid','select-acid');click('Collection.Confirm','confirm-acid');}
 else click('Draft.'+(round===2?'Axe':'Poison'),'select-'+round);
 phase(['Aim']);
 code(`local p=game:GetService("Players").LocalPlayer.PlayerGui;for _,b in p.BVSBallLabels.ReferenceCanvas:GetChildren() do if b:IsA("Frame") and b.Name:match("^Ball%d$") then local v=b.Model;assert(v.Sprite.IsLoaded and v.Sprite.Visible and v.ImageTransparency==1,"Ball atlas not visible");local width=v.Sprite.AbsoluteSize.X*88/128;local scale=${g}.ReferenceCanvas.UIScale.Scale;assert(math.abs(width/scale-82.23)<1,"Ball shell/collision mismatch") end end;return {ballArt=true,diameterContract=true}`,'ball-art-'+round);
 capture('aim-'+round);click('Controls.Primary','lock-'+round);phase(['Battle'],10);
 code('task.wait(6);return true','paint-progress-'+round);capture('battle-'+round);
 phase(['RoundResult','MatchResult'],32);capture('result-'+round);
 outcome=code(`local r=${g}.ReferenceCanvas;assert(r.Results.Visible);assert(not r.Panels.Visible and not r.Collection.Visible);return {phase=${g}:GetAttribute("Phase"),tick=workspace:GetAttribute("BVSTick"),a=workspace:GetAttribute("BVSCountA"),b=workspace:GetAttribute("BVSCountB"),reason=workspace:GetAttribute("BVSResultReason"),resultTitle=r.Results.ResultTitle.Text}`,'outcome-'+round);
 if(outcome.phase==='MatchResult')break;
}
phase(['MatchResult']);
capture('match-result');
outcome=code(`local r=${g}.ReferenceCanvas;assert(r.Results.Visible and not r.Panels.Visible);return {phase=${g}:GetAttribute("Phase"),tick=workspace:GetAttribute("BVSTick"),a=workspace:GetAttribute("BVSCountA"),b=workspace:GetAttribute("BVSCountB"),reason=workspace:GetAttribute("BVSResultReason"),resultTitle=r.Results.ResultTitle.Text}`,'final-outcome');
rpc('get_console_output',{},'console');
writeFileSync(outputFile(`${prefix}-result.json`),JSON.stringify({loaded,outcome,panels:true,equip:true,storeNavigation:true,queueCancellation:true,privateDraft:true,ballDiameter:true,completePractice:true},null,2));
