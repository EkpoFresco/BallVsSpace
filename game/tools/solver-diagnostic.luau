local M=require(game:GetService("ServerScriptService").Server.Services.MatchService)
local m=M.new("fixture",{1,2},49,0,true);M.beginRound(m,0)
for i,s in m.seats do s.kitId=if (49+i)%2==0 then "Drift" else "Anchor";s.pickLocked=true;s.interactedDraft=true end
M.update(m,3,0,true)
for i,s in m.seats do s.angle=(49*(if i==1 then 137 else 83)+i*29)%360;s.aimLocked=true;s.interactedAim=true end
M.update(m,5,0,true);M.update(m,7,0,true)
local trace={};local now=7
while m.sim.tick<270 and not m.resultLocked do
 now+=1/60;M.update(m,now,1/60,true)
 if m.sim.tick>258 then table.insert(trace,{tick=m.sim.tick,caps=m.sim.capHits,a=table.clone(m.sim.balls[1]),b=table.clone(m.sim.balls[2])}) end
end
return trace
