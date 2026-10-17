local S=game:GetService("ReplicatedStorage").Shared
local Services=game:GetService("ServerScriptService").Server.Services
local Match=require(Services.MatchService)
local Replication=require(Services.ReplicationService)
local Protocol=require(S.Protocol)
local Config=require(S.Config)
local Layout=require(game:GetService("StarterPlayer").StarterPlayerScripts.Client.Controllers.ReferenceLayout)
local m=Match.new("appearance-test",{11,22},3,0,false)
Match.beginRound(m,0)
local function command(kit,appearance)
return {id=1,kind="Select",matchId=m.id,roundId=m.roundId,generation=m.generation,kitId=kit,appearance=appearance}
end
assert(Match.command(m,11,command("Anchor","Axe"),.5),"Valid appearance rejected")
assert(m.seats[1].appearance=="Axe","Appearance not stored")
local before=m.stateVersion
assert(not Match.command(m,11,command("Drift","Axe"),.8),"Cross-kit appearance accepted")
assert(not Match.command(m,11,command("Drift","Unknown"),.8),"Unknown appearance accepted")
assert(m.stateVersion==before and m.seats[1].kitId=="Anchor","Rejected appearance mutated seat")
assert(Protocol.command(command("Drift",string.rep("a",17)))==nil,"Overlong appearance accepted")
local private=Replication.stateFor(m,22)
assert(private.seats[1].appearance==nil and private.seats[1].kitId==nil,"Private draft leaked")
m.phase="Aim"
local revealed=Replication.stateFor(m,22)
assert(revealed.seats[1].appearance=="Axe","Appearance failed reveal")
local radiusPixels=Config.Radius*446/64
local right=Layout.ball(Config.CenterBound,0)
assert(math.abs(right.X+radiusPixels-624)<.001,"Visible sphere misses collision wall")
assert(math.abs(Layout.ball(-Config.SpawnX,0).X-269)<2,"Opening composition differs from reference")
return {passed=8,appearanceValidation=true,draftPrivacy=true,bodyDiameterPixels=radiusPixels*2,innerCourtPixels=446,spawnX=Layout.ball(-Config.SpawnX,0).X,motionVersion=Config.MotionVersion}
