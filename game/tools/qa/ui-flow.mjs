import {readFileSync,writeFileSync} from 'node:fs';
import {gameRoot,outputFile} from '../lib/project.mjs';
import {createQa} from '../studio/client.mjs';
const studio=process.argv[2],prefix=process.argv[3]||'ui-flow';
if(!studio)throw Error('Explicit verified Studio ID required');
process.chdir(gameRoot);
const rpc=createQa(studio,prefix);
const code=(value,label)=>rpc('execute_luau',{datamodel_type:'Client',code:value},label);
const click=(path,label)=>{const point=code(`local n=game.Players.LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas;for part in string.gmatch(${JSON.stringify(path)},'[^.]+') do n=n:FindFirstChild(part);assert(n) end;local a=n.Parent;while a do if a:IsA('ScrollingFrame') and a.ScrollingEnabled then local delta=n.AbsolutePosition.Y-a.AbsolutePosition.Y;if delta<0 or delta+n.AbsoluteSize.Y>a.AbsoluteSize.Y then a.CanvasPosition=Vector2.new(0,math.clamp(a.CanvasPosition.Y+delta-8,0,math.max(0,a.AbsoluteCanvasSize.Y-a.AbsoluteSize.Y))) end end;a=a.Parent end;task.wait(.1);local g=game.Players.LocalPlayer.PlayerGui.BallVsSpace;local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=g.Parent;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy();local p=n.AbsolutePosition+n.AbsoluteSize/2+offset;return {x=p.X,y=p.Y}`,'point-'+label);return rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'moveTo',...(landscape?point:{instance_path:'LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas.'+path})},{action:'wait',wait_time_ms:100},{action:'mouseButtonDown',mouse_button:'left'},{action:'wait',wait_time_ms:80},{action:'mouseButtonUp',mouse_button:'left'},{action:'wait',wait_time_ms:250}]},label);};
const capture=label=>rpc('screen_capture',{capture_id:label},label);
const g='game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace';
function phase(allowed,seconds=15){
 const r=code(`local g=${g};local limit=os.clock()+${seconds};repeat task.wait(.1) until table.find({${allowed.map(x=>JSON.stringify(x)).join(',')}},g:GetAttribute("Phase")) or os.clock()>limit;return if g:GetAttribute("Phase")=="Lobby" and g:GetAttribute("QACompletedMatch") then "MatchResult" else g:GetAttribute("Phase")`,'wait-'+allowed.join('-'));
 if(!allowed.includes(r))throw Error('Unexpected phase '+r); return r;
}
function panel(name){code(`local r=${g}.ReferenceCanvas;local untilTime=os.clock()+3;repeat task.wait(.05) until r.Panels[${JSON.stringify(name)}].Visible or os.clock()>untilTime;local p=r.Panels[${JSON.stringify(name)}];assert(r.Panels.Visible and p.Visible);task.wait(.2);local g=${g};local center=p.AbsolutePosition+p.AbsoluteSize/2-g.AbsolutePosition;assert(math.abs(center.X-g.AbsoluteSize.X/2)<1,"Modal not centered");local pos=p.AbsolutePosition-g.AbsolutePosition;assert(pos.X>=-1 and pos.Y>=-1 and pos.X+p.AbsoluteSize.X<=g.AbsoluteSize.X+1 and pos.Y+p.AbsoluteSize.Y<=g.AbsoluteSize.Y+1,"Modal clipped");return {centered=true,withinSafeArea=true}`,'panel-'+name)}
phase(['Lobby']);
const landscape=process.argv.includes('--landscape');
if(landscape)code(readFileSync('tools/qa/devices/phone.luau','utf8'),'phone-landscape');
else code(`local svc=game:GetService('StudioDeviceSimulatorService');for _,id in svc:GetDeviceListAsync() do if svc:GetDeviceInfoAsync(id).Name=='Average Laptop' then svc:SetDeviceAsync(id);break end end;svc:SetResolutionAsync(1280,900);task.wait(.3);return true`,'desktop');

const loaded=code(`local p=game:GetService("Players").LocalPlayer.PlayerGui;local deadline=os.clock()+15;local missing,count;repeat missing={};count=0;for _,i in p:GetDescendants() do if i:IsA("ImageLabel") and i:GetAttribute("ArtworkId") then local visible=true;local ancestor=i;while ancestor and ancestor~=p do if ancestor:IsA("GuiObject") and not ancestor.Visible then visible=false;break end;ancestor=ancestor.Parent end;if visible then count+=1;if not i.IsLoaded then table.insert(missing,i:GetFullName()) end end end end;if #missing>0 then task.wait(.2) end until #missing==0 or os.clock()>deadline;assert(#missing==0,table.concat(missing,","));return {authoredImages=count,loaded=true}`, 'assets-loaded');
code(`local g=${g};g:SetAttribute('QACompletedMatch',nil);local s=Instance.new('LocalScript');s.Name='QAResultWitness';s.Source=[=[local g=script.Parent.BallVsSpace;g:GetAttributeChangedSignal('Phase'):Connect(function() if g:GetAttribute('Phase')=='MatchResult' then task.wait(.15);local r=g.ReferenceCanvas;g:SetAttribute('QACompletedMatch',game:GetService('HttpService'):JSONEncode({phase='MatchResult',tick=workspace:GetAttribute('BVSTick'),a=workspace:GetAttribute('BVSCountA'),b=workspace:GetAttribute('BVSCountB'),reason=workspace:GetAttribute('BVSResultReason'),resultTitle=r.Results.ResultTitle.Text,resultVisible=r.Results.Visible,panelsClosed=not r.Panels.Visible,observedAt=os.clock()})) end end)]=];s.Parent=g.Parent;return true`,'result-witness');
capture('lobby');
const matchOnly=process.argv.includes('--match-only');
if(!matchOnly){
click('Lobby.Inventory','inventory');panel('Inventory');
code(`local d=${g}.ReferenceCanvas.Panels.Inventory.Content.BallsPage.Details;local name=d:FindFirstChild('Name');local oldName,oldText=name.Text,d.Description.Text;for id,e in require(game.ReplicatedStorage.Shared.AppearanceCatalog).entries do name.Text=e.name;d.Description.Text=string.gsub(e.description,'\\n',' ');task.wait();assert(name.TextFits,id..' name clipped');assert(d.Description.TextFits,id..' description clipped') end;name.Text=oldName;d.Description.Text=oldText;return true`,'all-description-fit');capture('inventory');
click('Panels.Inventory.Content.BallsPage.Grid.Axe','select-axe');click('Panels.Inventory.Content.BallsPage.Details.Equip','equip-axe');
code(`assert(${g}.ReferenceCanvas.Panels.Inventory.Content.BallsPage.Details.Equipped.Text=="Equipped: Axe");return true`,'equip-feedback');
click('Panels.Inventory.Explosions','explosions');capture('explosions');click('Panels.Inventory.Flyers','flyers');capture('flyers');click('Panels.Inventory.Close','close-inventory');
click('Lobby.Store','store');panel('Store');capture('store');click('Panels.Store.Content.Offers.ViewLaser','inspect-laser');panel('Inventory');
code(`assert(${g}.ReferenceCanvas.Panels.Inventory.Content.BallsPage.Details:FindFirstChild("Name").Text=="Laser Ball");return true`,'store-detail');click('Panels.Inventory.Close','close-detail');
for(const [button,name] of [['Rewards','Rewards'],['Lobby.Emotes','Emotes'],['Lobby.Trade','Trade'],['Lobby.Invite','Invite friends'],['Lobby.Mode','Play']]){
 click(button,'open-'+name);panel(name);capture(name.toLowerCase().replaceAll(' ','-'));click('Panels.'+name+'.Close','close-'+name);
}
click('Settings','settings');capture('settings');click('SettingsPanel.Close','close-settings');
click('Controls.Left','queue');phase(['Queued']);capture('queue');click('Controls.Primary','cancel');phase(['Lobby']);
}
if(process.argv.includes('--menus-only')){writeFileSync(outputFile(`${prefix}-result.json`),JSON.stringify({menus:true,landscapePhoneEmulation:landscape,physicalDevice:false},null,2));process.exit(0);}
click('Lobby.Practice','practice');
let outcome;
for(let round=1;round<=3;round++){
 const entering=phase(['Draft','MatchResult'],40);if(entering==='MatchResult')break;
 code(`local r=${g}.ReferenceCanvas;for i=1,2 do local side=r["PlayerSide"..i];local v=side.KitIcon;if side.PlayerFigure:GetAttribute("UserId")~=game:GetService("Players").LocalPlayer.UserId then assert(v.Unknown.Visible and not v.Sprite.Visible,"Opponent draft appearance visible") else assert(v.Sprite.Visible,"Own draft preview missing") end end;return true`,'private-draft-'+round);
 code(`local r=${g}.ReferenceCanvas;for _,b in r.Draft:GetChildren() do local bg=b:FindFirstChild('PreviewBackground');local v=bg and bg:FindFirstChild('KitPreview');if v and v.Sprite.IsLoaded then assert(v.ImageTransparency==1,'Loaded draft sprite overlaps fallback') end end;return true`,'draft-art-'+round);
 capture('draft-'+round);
 if(round===1){click('Draft.AllBalls','all-balls');capture('collection');click('Collection.Acid','select-acid');click('Collection.Confirm','confirm-acid');}
 else click('Draft.'+(round===2?'Axe':'Poison'),'select-'+round);
 phase(['Aim']);
 code(`local p=game:GetService("Players").LocalPlayer.PlayerGui;for _,b in p.BVSBallLabels.ReferenceCanvas:GetChildren() do if b:IsA("Frame") and b.Name:match("^Ball%d$") then local v=b.Model;assert(v.Sprite.IsLoaded and v.Sprite.Visible and v.ImageTransparency==1,"Ball atlas not visible");local width=v.Sprite.AbsoluteSize.X*88/128;local scale=${g}.ReferenceCanvas.UIScale.Scale;assert(math.abs(width/scale-82.23)<1,"Ball shell/collision mismatch") end end;return {ballArt=true,diameterContract=true}`,'ball-art-'+round);
 if(round===1){
 rpc('execute_luau',{datamodel_type:'Server',code:`local observer=Instance.new('Script');observer.Name='QAInputObserver';observer.Source=[[game.ReplicatedStorage.Remotes.ClientCommand.OnServerEvent:Connect(function(_,raw) if raw.kind=='Aim' then workspace:SetAttribute('QAObservedAim',raw.angle) end end)]];observer.Parent=game.ServerScriptService;return true`},'observe-aim');
 const point=code(`local p=game.Players.LocalPlayer;local g=${g};local r=g.ReferenceCanvas;local index=if r.PlayerSide1.PlayerFigure:GetAttribute('UserId')==p.UserId then 1 else 2;local ball=p.PlayerGui.BVSBallLabels.ReferenceCanvas['Ball'..index];local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=p.PlayerGui;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy();local target=ball.AbsolutePosition+ball.AbsoluteSize/2+Vector2.new(60,-60)+offset;return {x=target.X,y=target.Y}`,'diagonal-aim-point');
 rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonDown',mouse_button:'left',...point},{action:'wait',wait_time_ms:200},{action:'mouseButtonUp',mouse_button:'left'},{action:'wait',wait_time_ms:300}]},'drag-aim');
 rpc('execute_luau',{datamodel_type:'Server',code:`local deadline=os.clock()+3;repeat task.wait(.1) until workspace:GetAttribute('QAObservedAim') or os.clock()>deadline;local a=workspace:GetAttribute('QAObservedAim');assert(a and math.abs(a-315)<=1,'Aim input does not match visible diagonal: '..tostring(a));return {angle=a,expected=315}`},'aim-input-aligned');
 }
 capture('aim-'+round);click('Controls.Primary','lock-'+round);phase(['Battle'],10);
 code('task.wait(6);return true','paint-progress-'+round);capture('battle-'+round);
 if(round===1&&process.argv.includes('--help-check')){
  click('HelpButton','open-help');panel('How to play');
  code(`local g=${g};local p=g.ReferenceCanvas.Panels['How to play'];for _,n in p:GetDescendants() do if n:IsA('TextLabel') and n.Visible and n.Text~='' then assert(n.TextFits,n:GetFullName()..' clipped') end end;assert(not game:GetService('GuiService').TouchControlsEnabled);return {textFits=true,nativeMovementHidden=true}`,'help-layout');
  capture('how-to-play');click('Panels.How to play.Close','close-help');
 }

 outcome=code(`local g=${g};local deadline=os.clock()+32;repeat task.wait(.1) until g:GetAttribute('Phase')=='RoundResult' or g:GetAttribute('Phase')=='MatchResult' or os.clock()>deadline;local r=g.ReferenceCanvas;assert(r.Results.Visible);assert(not r.Panels.Visible and not r.Collection.Visible);return {phase=${g}:GetAttribute("Phase"),tick=workspace:GetAttribute("BVSTick"),a=workspace:GetAttribute("BVSCountA"),b=workspace:GetAttribute("BVSCountB"),reason=workspace:GetAttribute("BVSResultReason"),resultTitle=r.Results.ResultTitle.Text}`,'outcome-'+round);
 capture('result-'+round);
 if(outcome.phase==='MatchResult')break;
}
phase(['MatchResult']);
let resultActions;
if(process.argv.includes('--result-actions')){
 const points=code(`local g=${g};assert(g:GetAttribute('Phase')=='MatchResult','Result actions missed the result window');local r=g.ReferenceCanvas;assert(r.Controls.Left.Visible and r.Controls.Primary.Visible);local probe=Instance.new('ScreenGui');probe.ScreenInsets=Enum.ScreenInsets.None;probe.Parent=g.Parent;task.wait();local offset=g.AbsolutePosition-probe.AbsolutePosition;probe:Destroy();local function point(n) local p=n.AbsolutePosition+n.AbsoluteSize/2+offset;return {x=p.X,y=p.Y} end;local s=Instance.new('LocalScript');s.Name='QAResultActions';s.Source=[=[local g=script.Parent.BallVsSpace;local r=g.ReferenceCanvas;local started,restored=false,false;local deadline=os.clock()+7;repeat task.wait();if r.Status.Visible and string.find(r.Status.Text,'REPLAY',1,true) and not r.Results.Visible then started=true end;if started and r.Results.Visible and r.Controls.Left.Visible then restored=true end;if restored and r.Controls.Primary.Text=='Queued ✓' then task.wait(.4);assert(r.Controls.Primary.Text=='Queued ✓','Rematch feedback was overwritten');g:SetAttribute('QAResultActions',game:GetService('HttpService'):JSONEncode({replayStarted=started,resultRestored=restored,rematchConfirmed=true}));return end until os.clock()>deadline;g:SetAttribute('QAResultActions',game:GetService('HttpService'):JSONEncode({replayStarted=started,resultRestored=restored,rematchConfirmed=false}))]=];s.Parent=g.Parent;return {replay=point(r.Controls.Left),rematch=point(r.Controls.Primary)}`,'result-action-points');
 rpc('user_mouse_input',{datamodel_type:'Client',actions:[{action:'mouseButtonClick',mouse_button:'left',...points.replay},{action:'wait',wait_time_ms:2300},{action:'mouseButtonClick',mouse_button:'left',...points.rematch},{action:'wait',wait_time_ms:600}]},'replay-and-rematch');
 resultActions=code(`local g=${g};local deadline=os.clock()+3;repeat task.wait(.05) until g:GetAttribute('QAResultActions') or os.clock()>deadline;local raw=g:GetAttribute('QAResultActions');assert(raw,'Result actions were not observed');local r=game:GetService('HttpService'):JSONDecode(raw);assert(r.replayStarted and r.resultRestored and r.rematchConfirmed,raw);return r`,'result-actions-verified');
}
const live=code(`return ${g}:GetAttribute('Phase')`,'current-final-phase');
capture(live==='MatchResult'?'match-result':'lobby-after-completed-match');
outcome=code(`local g=${g};local raw=g:GetAttribute('QACompletedMatch');assert(raw,'Match completion was not observed');local result=game:GetService('HttpService'):JSONDecode(raw);assert(result.resultVisible and result.panelsClosed and result.reason=='match_points');return result`,'final-outcome');
rpc('get_console_output',{},'console');
writeFileSync(outputFile(`${prefix}-result.json`),JSON.stringify({loaded,outcome,panels:!matchOnly,equip:!matchOnly,storeNavigation:!matchOnly,queueCancellation:!matchOnly,privateDraft:true,ballDiameter:true,completePractice:true,resultActions,landscapePhoneEmulation:landscape,physicalDevice:false},null,2));
