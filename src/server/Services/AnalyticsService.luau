--!strict
export type Event = { kind: string, tick: number, a: number, b: number, reason: string }
local Analytics = {}
function Analytics.record(trace: { Event }, kind: string, tick: number, a: number, b: number, reason: string)
	if #trace >= 200 then
		table.remove(trace, 1)
	end
	table.insert(trace, { kind = kind, tick = tick, a = a, b = b, reason = reason })
end
return table.freeze(Analytics)
