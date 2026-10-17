local shared = game:GetService("ReplicatedStorage").Shared
local territory = require(game:GetService("ServerScriptService").Server.Services.TerritoryService)
local mathGrid = require(shared.TerritoryMath)
local a, b = territory.new(), territory.new()
local shapes = {
 {ax=-6,az=0,bx=2,bz=0,radius=7,team=1,strength=2},
 {ax=3,az=-5,bx=3,bz=5,radius=6,team=2,strength=1},
}
local function frame(name, board)
 local cells={}
 for i=0,1023 do cells[i+1]=buffer.readi8(board.q,i) end
 return {name=name,cells=cells,cyan=board.counts[1],coral=board.counts[2],neutral=board.counts[0],hash=mathGrid.hash(board.q)}
end
local frames={frame("Before: neutral grid",a)}
territory.resolve(a,{},shapes)
territory.resolve(b,{}, {shapes[2],shapes[1],shapes[1]})
assert(buffer.tostring(a.q)==buffer.tostring(b.q),"Order/duplicate equality")
table.insert(frames,frame("After: simultaneous A2 / B1",a))
table.insert(frames,frame("Reversed + duplicate A: identical",b))
local reinforced=3
local capture={reinforced}
for _=1,4 do reinforced=mathGrid.resolve(reinforced,0,1,false);table.insert(capture,reinforced) end
return {frames=frames,reinforcedCapture=capture,equal=true,source="Server.Services.TerritoryService.resolve in actual Studio Edit DataModel"}
