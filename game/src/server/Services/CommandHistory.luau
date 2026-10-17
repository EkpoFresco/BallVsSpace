--!strict
-- Retries receive their original acknowledgement without executing twice.
export type Result = { accepted: boolean, reason: string }
export type State = { latest: number, ids: { number }, results: { [number]: Result } }
local History = {}
function History.new(): State
	return { latest = 0, ids = {}, results = {} }
end
function History.lookup(state: State, id: number): Result?
	return state.results[id]
end
function History.record(state: State, id: number, accepted: boolean, reason: string)
	assert(id > state.latest, "Command IDs must increase")
	state.latest = id
	state.results[id] = { accepted = accepted, reason = reason }
	table.insert(state.ids, id)
	if #state.ids > 64 then
		local oldest = table.remove(state.ids, 1)
		assert(oldest, "Nonempty acknowledgement cache")
		state.results[oldest] = nil
	end
end
return table.freeze(History)
