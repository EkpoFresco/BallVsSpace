--!strict
local TerritoryMath = {}
function TerritoryMath.owner(q: number): number
	return if q > 0 then 1 elseif q < 0 then 2 else 0
end
function TerritoryMath.resolve(q: number, a: number, b: number, drain: boolean): number
	if drain then
		q -= math.sign(q)
	end
	return math.clamp(q + a - b, -3, 3)
end
function TerritoryMath.count(q: buffer): { number }
	local counts = { [0] = 0, [1] = 0, [2] = 0 }
	for i = 0, 1023 do
		counts[TerritoryMath.owner(buffer.readi8(q, i))] += 1
	end
	return counts
end
function TerritoryMath.hash(q: buffer): number
	local hash = 0
	for i = 0, 1023 do
		hash = (hash * 31 + buffer.readi8(q, i) + 3) % 2147483647
	end
	return hash
end
return table.freeze(TerritoryMath)
