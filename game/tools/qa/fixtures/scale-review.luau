-- Render the real UI modules at Studio emulator resolutions without match-clock races.
-- This fixture checks presentation; ui-flow separately proves live input and server behavior.
local player = game.Players.LocalPlayer
local modules = player.PlayerScripts.Client.Controllers
local Hud = require(modules.HudController)
local Panels = require(modules.LobbyPanels)
local catalog = require(game.ReplicatedStorage.Shared.AppearanceCatalog)
local disabled = {}
for _, gui in player.PlayerGui:GetChildren() do
 if gui:IsA('ScreenGui') and gui.Name:match('^BVS') or gui.Name=='BallVsSpace' then
  disabled[gui]=gui.Enabled;gui.Enabled=false
 end
end
local h=Hud.new()
h.gui.Name='QAScaleReview';h.gui.DisplayOrder=100
h.courtGui.Name='QAScaleCourt';h.courtGui.DisplayOrder=99
h.panels.layer:SetAttribute('ReducedMotion',true)
local Review={}
local function visible(node,root)
 local a=node
 while a and a~=root.Parent do
  if a:IsA('GuiObject') and not a.Visible then return false end
  a=a.Parent
 end
 return true
end
local function factor(node)
 local scale=1;local a=node
 while a do
  local s=a:FindFirstChildOfClass('UIScale');if s then scale*=s.Scale end
  a=a.Parent
 end
 return scale
end
function Review.show(name)
 Panels.close(h.panels);h.collection.Visible=false;h.settingsPanel.Visible=false;h.panels.toast.Visible=false;h.status.Visible=false
 local phase=if name=='Draft' or name=='Collection' then 'Draft' elseif name=='Aim' then 'Aim' elseif name=='Battle' then 'Battle' elseif name=='Overtime' then 'Overtime' elseif name=='Countdown' then 'Countdown' elseif name=='Round result' then 'RoundResult' elseif name=='Results' or name=='Rematch queued' or name=='Service result' then 'MatchResult' elseif name=='Connection delayed' or name=='Replay' then 'Battle' elseif name=='Queued' then 'Queued' else 'Lobby'
 Hud.layout(h,phase)
 h.phase.Text='SET YOUR DIRECTION';h.timer.Text='0:30';h.points.Text='1 — 0';h.scoreA.Text='47.8%';h.scoreB.Text='24.7%'
 h.primary.Text=if phase=='MatchResult' then 'Rematch' elseif phase=='Queued' then 'Leave' else 'Lock Aim'
 h.help.Text='Waiting for another player…'
 for i,n in h.sideLabels do n.Text=if i==1 then 'LongestDisplayNameTest' else 'Practice opponent' end
 for i,n in h.kitNames do n.Text=if i==1 then 'Poison Canister' else 'Vampire' end
 local root=h.root
 if h.panels.windows[name] then Panels.open(h.panels,name);root=h.panels.windows[name]
 elseif name:match('^Inventory:') then
  Panels.open(h.panels,'Inventory');local category=name:sub(11)
  for i,p in h.panels.inventoryPages do p.Visible=({'Balls','Explosions','Flyers','Fusion'})[i]==category end
  root=h.panels.windows.Inventory
 elseif name=='Settings' then h.settingsPanel.Visible=true;root=h.settingsPanel
 elseif name=='Collection' then h.collection.Visible=true;root=h.collection
 elseif name=='Draft' then root=h.draft
 elseif name=='Results' or name=='Round result' or name=='Rematch queued' or name=='Service result' then
  local view={id='scale',phase=phase,generation=1,roundId=3,roundNumber=3,deadline=100,tick=1800,points2={4,2},winner=if name=='Service result' then 0 else 1,reason=if name=='Service result' then 'simulation_debt' else 'match_points',practice=true,offer={'Drift','Anchor'},wildcardUsed=false,localKit='Drift',localAngle=0,hold=0,holdLeader=0,persistence='Session only',rematchRequested=name=='Rematch queued',seats={{id=1,userId=player.UserId,team=1,name='LongestDisplayNameTest',kitId='Drift',appearance='Acid',pickLocked=true,aimLocked=true,x=-19,z=0},{id=2,userId=-999999,team=2,name='Practice opponent',kitId='Anchor',appearance='Axe',pickLocked=true,aimLocked=true,x=19,z=0}}}
  Hud.render(h,view,phase,{q=buffer.create(1024),counts={[0]=282,[1]=489,[2]=253},version=1},true)
  root=h.result
 elseif name=='Connection delayed' or name=='Replay' then
  h.status.Visible=true;h.status.Text=if name=='Replay' then 'REPLAY · last 2 seconds · result locked' else 'Connection delayed · waiting for server';root=h.status
 elseif name=='Toast' then Panels.notify(h.panels,'This avatar does not support that emote. Try another emote.');root=h.panels.toast
 end
 task.wait(.12)
 return root
end
function Review.inspect(name)
 local root=Review.show(name);local issues={};local texts,buttons=0,0;local smallest=1000;local targets={}
 local nodes=root:GetDescendants();table.insert(nodes,root)
 for _,n in nodes do
  if not n:IsA('GuiObject') or not visible(n,root) then continue end
  if n:IsA('TextLabel') and n.Text~='' and n.TextTransparency<.5 then
   texts+=1;local size=n.TextSize*factor(n);smallest=math.min(smallest,size)
   if not n.TextFits and n.TextTruncate==Enum.TextTruncate.None then table.insert(issues,{kind='text-fit',path=n:GetFullName(),text=n.Text,size=size,box=tostring(n.AbsoluteSize)}) end
   if size<10.99 then table.insert(issues,{kind='font-small',path=n:GetFullName(),text=n.Text,size=size}) end
  end
  if n:IsA('GuiButton') then
   buttons+=1
   if n.Name~='Dismiss' then
    local p,q=n.AbsolutePosition,n.AbsolutePosition+n.AbsoluteSize;local a=n.Parent
    while a do if a:IsA('GuiObject') and a.ClipsDescendants then p=Vector2.new(math.max(p.X,a.AbsolutePosition.X),math.max(p.Y,a.AbsolutePosition.Y));q=Vector2.new(math.min(q.X,a.AbsolutePosition.X+a.AbsoluteSize.X),math.min(q.Y,a.AbsolutePosition.Y+a.AbsoluteSize.Y)) end;a=a.Parent end
    if q.X>p.X and q.Y>p.Y then table.insert(targets,{node=n,p=p,s=q-p}) end
   end
   if n.Name~='Dismiss' and (n.AbsoluteSize.X<43.5 or n.AbsoluteSize.Y<43.5) then table.insert(issues,{kind='target-small',path=n:GetFullName(),size=tostring(n.AbsoluteSize)}) end
  end
 end
 for i,a in targets do
  for j=i+1,#targets do
   local b=targets[j]
   if not a.node:IsDescendantOf(b.node) and not b.node:IsDescendantOf(a.node) then
    local ap,as,bp,bs=a.p,a.s,b.p,b.s
    local overlap=Vector2.new(math.min(ap.X+as.X,bp.X+bs.X)-math.max(ap.X,bp.X),math.min(ap.Y+as.Y,bp.Y+bs.Y)-math.max(ap.Y,bp.Y))
    if overlap.X>2 and overlap.Y>2 then table.insert(issues,{kind='targets-overlap',path=a.node:GetFullName(),other=b.node:GetFullName(),overlap=tostring(overlap)}) end
   end
  end
 end
 if h.primary.Visible then
  local center=h.primary.AbsolutePosition.X+h.primary.AbsoluteSize.X/2-h.gui.AbsolutePosition.X
  if math.abs(center-h.gui.AbsoluteSize.X/2)>1 then table.insert(issues,{kind='primary-not-centered',path=h.primary.Name,offset=center-h.gui.AbsoluteSize.X/2}) end
 end
 if root~=h.root then
  local p=root.AbsolutePosition-h.gui.AbsolutePosition;local s=root.AbsoluteSize;local v=h.gui.AbsoluteSize
  if p.X<-.5 or p.Y<-.5 or p.X+s.X>v.X+.5 or p.Y+s.Y>v.Y+.5 then table.insert(issues,{kind='outside-safe',path=root.Name,position=tostring(p),size=tostring(s),viewport=tostring(v)}) end
 end
 return {frame=name,texts=texts,buttons=buttons,minimumFont=smallest,issues=issues}
end
function Review.all()
 local rows={}
 for _,name in {'Lobby','Queued','Inventory:Balls','Inventory:Explosions','Inventory:Flyers','Inventory:Fusion','Store','Rewards','Play','How to play','Trade','Emotes','Invite friends','Settings','Draft','Collection','Aim','Countdown','Battle','Overtime','Results','Round result','Rematch queued','Service result','Connection delayed','Replay','Toast'} do table.insert(rows,Review.inspect(name)) end
 -- Exercise all catalog strings in both selection surfaces.
 for _,id in catalog.ids do
  Review.show('Inventory:Balls');Panels.select(h.panels,id);task.wait()
  for _,n in {h.panels.detailName,h.panels.detailText} do assert(n.TextFits,id..' inventory copy clipped') end
 end
 for offset=0,11,3 do
  Review.show('Draft');Hud.reroll(h,offset);task.wait()
  for _,c in h.cards do
   for _,key in {'Title','Description'} do local n=c[key];if not n.TextFits then table.insert(rows,{frame='Draft:'..c.Name,issues={{kind='catalog-fit',path=key,text=n.Text,box=tostring(n.AbsoluteSize)}}}) end end
  end
 end
 return {viewport=tostring(h.gui.AbsoluteSize),touch=game:GetService('UserInputService').TouchEnabled,rows=rows}
end
function Review.destroy()
 h.gui:Destroy();h.courtGui:Destroy()
 for gui,enabled in disabled do if gui.Parent then gui.Enabled=enabled end end
end
return Review
