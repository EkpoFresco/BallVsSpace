--!strict
local Draft = {}
function Draft.offers(seed: number, round: number, slotPair: number, catalog: { string }): { string }
	local ids = table.clone(catalog)
	table.sort(ids)
	-- Park–Miller PRNG, rejection sampling avoids modulo selection bias.
	local state = (math.abs(math.floor(seed)) + round * 104729 + slotPair * 7919) % 2147483646 + 1
	for i = #ids, 2, -1 do
		local limit = 2147483646 - 2147483646 % i
		local value: number
		repeat
			state = (state * 16807) % 2147483647
			value = state - 1
		until value < limit
		local j = value % i + 1
		ids[i], ids[j] = ids[j], ids[i]
	end
	local offered = {}
	for i = 1, math.min(3, #ids) do
		table.insert(offered, ids[i])
	end
	return offered
end
return table.freeze(Draft)
