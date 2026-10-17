--!strict
export type Hold = { leader: number, updates: number }
local Rules = {}
function Rules.evaluate(tick: number, a: number, b: number, hold: Hold): (boolean, number, boolean)
	if tick == 1800 then
		return a ~= b, if a > b then 1 elseif b > a then 2 else 0, a == b
	end
	if tick < 1800 then
		return false, 0, false
	end
	local leader = if a - b >= 2 then 1 elseif b - a >= 2 then 2 else 0
	if leader == 0 then
		hold.updates = 0
	elseif leader == hold.leader then
		hold.updates += 1
	else
		hold.updates = 1
	end
	hold.leader = leader
	if hold.updates >= 10 then
		return true, leader, false
	end
	return tick >= 2700, 0, false
end
function Rules.matchFinished(round: number, a2: number, b2: number): boolean
	return round >= 3 or a2 >= 4 or b2 >= 4
end
return table.freeze(Rules)
