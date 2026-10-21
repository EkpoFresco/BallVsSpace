-- Accelerated canonical Luau simulation, not a real-time multiplayer or balance claim.
local Match=require(game.ServerScriptService.Server.Services.MatchService)
local Heroes=require(game.ReplicatedStorage.Shared.HeroDefinitions)
local started=os.clock()
local function play(a,b,seed)
 local m=Match.new('roster-'..seed,{11,22},seed,0,false)
 Match.beginRound(m,0)
 for i,s in m.seats do s.kitId=if i==1 then a else b;s.appearance=s.kitId;s.pickLocked=true;s.interactedDraft=true end
 Match.update(m,3,0,true)
 for i,s in m.seats do s.angle=(seed*17+(i-1)*180)%360;s.aimLocked=true;s.interactedAim=true end
 Match.update(m,5,0,true);Match.update(m,7,0,true)
 for tick=1,2700 do
  Match.update(m,7+tick/60,1/60,true)
  if m.roundLocked or m.resultLocked then break end
  if tick%120==0 then task.wait() end
 end
 assert(m.roundLocked and not m.resultLocked,'Round aborted: '..m.reason)
 assert(m.sim.recoveries<=3,'Repeated solver recovery')
 return m
end
local rows={}
for i,id in Heroes.ids do
 local opponent=Heroes.ids[(i+12)%30+1]
 local a,b=play(id,opponent,i),play(opponent,id,i)
 assert(a.sim.tick==b.sim.tick and a.reason==b.reason,'Starting side changes cutoff: '..id)
 assert(a.board.counts[1]==b.board.counts[2] and a.board.counts[2]==b.board.counts[1],'Starting side changes area: '..id)
 assert(a.sim.balls[1].weapon.hp==b.sim.balls[2].weapon.hp and a.sim.balls[2].weapon.hp==b.sim.balls[1].weapon.hp,'Starting side changes HP: '..id)
 for cell=0,1023 do assert(buffer.readi8(a.board.q,cell)==-buffer.readi8(b.board.q,1023-cell),'Mirrored grid mismatch: '..id) end
 table.insert(rows,{hero=id,opponent=opponent,tick=a.sim.tick,reason=a.reason,winner=a.winner,a=a.board.counts[1],b=a.board.counts[2],hpA=a.sim.balls[1].weapon.hp,hpB=a.sim.balls[2].weapon.hp})
end
return {pairs=30,rounds=60,heroes=30,mirroredCells=30*1024,seconds=os.clock()-started,rows=rows,scope='Accelerated canonical simulation; not 60 real-time multiplayer rounds or proven roster balance'}
