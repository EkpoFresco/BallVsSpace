local Renderer=require(game.Players.LocalPlayer.PlayerScripts.Client.Controllers.TerritoryRenderer)
local state=Renderer.new();state.gui.Name='QATerritoryBenchmark'
local ok,result=pcall(function()
 local boards={}
 for frame=1,30 do
  local q=buffer.create(1024)
  for i=0,1023 do buffer.writei8(q,i,(i+frame)%7-3) end
  boards[frame]={q=q,counts={[0]=0,[1]=0,[2]=0},version=frame}
 end
 Renderer.apply(state,boards[1]);task.wait()
 local batches={}
 for batch=1,12 do
  local start=os.clock()
  for _,board in boards do Renderer.apply(state,board) end
  batches[batch]=(os.clock()-start)*1000/#boards;task.wait()
 end
 table.sort(batches)
 local start=os.clock()
 for _=1,1000 do Renderer.apply(state,boards[#boards]) end
 local repeatMs=(os.clock()-start)*1000/1000
 for i=0,1023 do assert(buffer.readi8(state.q,i)==buffer.readi8(boards[#boards].q,i),'Board rendering lost a cell') end
 return {descendants=#state.gui:GetDescendants(),tiles=#state.tiles,changedBoardMedianMs=batches[6],sameBoardMeanMs=repeatMs,iterations=360,method='12 batches of 30 fully changed immutable boards, then 1000 repeated draws. CPU calls only; not device FPS.'}
end)
state.gui:Destroy();assert(ok,result);return result
