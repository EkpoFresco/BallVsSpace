--!strict
local Config = require(script.Parent.Config)
local Arena = {}
function Arena.center(index: number): (number, number)
	assert(index >= 0 and index < 1024 and index % 1 == 0, "Invalid cell index")
	return -31 + 2 * (index % 32), -31 + 2 * (index // 32)
end
function Arena.index(x: number, z: number): number?
	if x < -32 or x >= 32 or z < -32 or z >= 32 then
		return nil
	end
	return math.floor((z + 32) / 2) * 32 + math.floor((x + 32) / 2)
end
function Arena.spawn(team: number, slot: number, round: number, teamSize: number): (number, number)
	local x = if team == 1 then -Config.SpawnX else Config.SpawnX
	if round % 2 == 0 then
		x = -x
	end
	local z = if teamSize == 1 then 0 elseif slot == 1 then -12 else 12
	return x, z
end
return table.freeze(Arena)
