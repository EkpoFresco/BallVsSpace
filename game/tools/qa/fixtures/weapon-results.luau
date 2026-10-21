local Hud=require(game.Players.LocalPlayer.PlayerScripts.Client.Controllers.HudController)
local Weapon=require(game.ReplicatedStorage.Shared.WeaponGeometry)
local h=Hud.new();h.gui.Name='BVSResultCheck'
local ok,result=pcall(function()
 local view={id='qa-result',phase='RoundResult',generation=1,roundId=1,roundNumber=1,deadline=100,tick=2700,points2={2,0},winner=1,reason='health_tiebreak',practice=true,offer={'Astra','Bram','Nix'},wildcardUsed=false,localKit='Astra',localAngle=0,hold=0,holdLeader=0,persistence='Session only',rematchRequested=false,seats={}}
 for i,id in {'Astra','Bram'} do view.seats[i]={id=i,userId=if i==1 then game.Players.LocalPlayer.UserId else -999999,team=i,name=id,kitId=id,appearance=id,pickLocked=true,aimLocked=true,x=0,z=0,weapon=Weapon.new(0,0,0)} end
 view.seats[1].weapon.hp=43;view.seats[2].weapon.hp=19
 local board={q=buffer.create(1024),counts={[0]=224,[1]=400,[2]=400},version=1}
 Hud.layout(h,'RoundResult');Hud.render(h,view,'RoundResult',board,true);task.wait()
 assert(h.resultMetric.Text=='HEALTH TIEBREAK' and h.resultScore.Text=='43 HP — 19 HP','Health result displays wrong metric')
 view.reason='knockout';view.seats[2].weapon.hp=0
 Hud.render(h,view,'RoundResult',board,true);task.wait()
 assert(h.resultMetric.Text=='KNOCKOUT' and h.resultScore.Text=='43 HP — 0 HP','KO must display health')
 view.reason='final_area';Hud.render(h,view,'RoundResult',board,true);task.wait()
 assert(h.resultMetric.Text=='FINAL TERRITORY' and string.find(h.resultScore.Text,'%%'),'Area must display percentages')
 return {healthMetric=true,knockoutMetric=true,territoryMetric=true}
end)
h.gui:Destroy();h.courtGui:Destroy();assert(ok,result);return result
