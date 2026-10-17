local Shared=game:GetService("ReplicatedStorage").Shared
local Services=game:GetService("ServerScriptService").Server.Services
local Catalog=require(Shared.BallCatalog)
local Math=require(Shared.TerritoryMath)
local Match=require(Services.MatchService)
local results={}
local samples={}
local start=os.clock()
local function run(seed,mirror)
 local m=Match.new("fixture",{1,2},seed,0,true)
 Match.beginRound(m,0)
 for i,s in m.seats do
  s.kitId=if (seed+i)%2==0 then "Drift" else "Anchor"
  s.pickLocked=true;s.interactedDraft=true
 end
 Match.update(m,3,0,true)
 for i,s in m.seats do
  local angle=(seed*(if i==1 then 137 else 83)+i*29)%360
  s.angle=if mirror then (180-angle)%360 else angle
  s.aimLocked=true;s.interactedAim=true
 end
 if mirror then for _,b in m.sim.balls do b.x=-b.x end end
 -- Mirrored initialization must mirror the stamped board too.
 if mirror then
  local original=m.board.q;local q=buffer.create(1024)
  for i=0,1023 do buffer.writei8(q,(i//32)*32+31-i%32,buffer.readi8(original,i)) end
  m.board.q=q
 end
 Match.update(m,5,0,true);Match.update(m,7,0,true)
 local now=7
 while not m.roundLocked and not m.resultLocked do
  now+=1/60
  local t=os.clock();Match.update(m,now,1/60,true)
  table.insert(samples,(os.clock()-t)*1000)
 end
 assert(not m.resultLocked,"Simulation aborted seed="..seed.." mirror="..tostring(mirror).." reason="..m.reason.." tick="..m.sim.tick.." caps="..m.sim.capHits)
 return m
end
for seed=1,200 do
 local a,b=run(seed,false),run(seed,true)
 assert(a.board.counts[1]==b.board.counts[1] and a.board.counts[2]==b.board.counts[2] and a.winner==b.winner,"Mirror score bias at seed "..seed)
 for i=0,1023 do assert(buffer.readi8(a.board.q,i)==buffer.readi8(b.board.q,(i//32)*32+31-i%32),"Mirror grid mismatch at seed "..seed) end
 table.insert(results,{seed=seed,a=a.board.counts[1],b=a.board.counts[2],winner=a.winner,ticks=a.sim.tick,recoveries=a.sim.recoveries+b.sim.recoveries,hash=Math.hash(a.board.q)})
 if seed%5==0 then task.wait() end
end
table.sort(samples)
return {pairs=#results,rounds=#results*2,seconds=os.clock()-start,stepP95Milliseconds=samples[math.ceil(#samples*.95)],stepMaxMilliseconds=samples[#samples],results=results}
