--!strict
local Config = require(script.Parent.Config)
local Types = require(script.Parent.Types)
export type Hold = { leader: number, updates: number }
local Rules = {}
function Rules.health(balls: { Types.Ball }): ({ number }, { number })
	local alive, sums, count = { 0, 0 }, { 0, 0 }, { 0, 0 }
	for _, b in balls do
		local hp = if b.weapon then b.weapon.hp else 100
		count[b.team] += 1
		sums[b.team] += hp / 100
		if hp > 0 then
			alive[b.team] += 1
		end
	end
	return alive, { sums[1] / math.max(1, count[1]), sums[2] / math.max(1, count[2]) }
end
function Rules.evaluate(tick: number, a: number, b: number, balls: { Types.Ball }): (boolean, number, string)
	local alive, health = Rules.health(balls)
	if alive[1] == 0 or alive[2] == 0 then
		return true,
			if alive[1] == 0 and alive[2] == 0 then 0 elseif alive[1] > 0 then 1 else 2,
			if alive[1] == 0 and alive[2] == 0 then "double_ko" else "knockout"
	end
	if tick < Config.BattleTicks then
		return false, 0, ""
	end
	if a ~= b then
		return true, if a > b then 1 else 2, "final_area"
	end
	if math.abs(health[1] - health[2]) > 1e-9 then
		return true, if health[1] > health[2] then 1 else 2, "health_tiebreak"
	end
	return true, 0, "equal_area_health"
end
function Rules.matchFinished(round: number, a2: number, b2: number): boolean
	return round >= 3 or a2 >= 4 or b2 >= 4
end
return table.freeze(Rules)
