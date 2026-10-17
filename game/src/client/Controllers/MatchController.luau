--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local Protocol = require(Shared.Protocol)
local Config = require(Shared.Config)
local Types = require(Shared.Types)
export type Sample = { tick: number, received: number, balls: { Protocol.Motion } }
export type State = { board: Types.Board, samples: { Sample }, latestTick: number, lastReceived: number }
local Controller = {}
function Controller.new(): State
	return {
		board = { q = buffer.create(1024), counts = { [0] = 1024, [1] = 0, [2] = 0 }, version = 0 },
		samples = {},
		latestTick = -1,
		lastReceived = os.clock(),
	}
end
function Controller.receive(state: State, payload: buffer)
	local balls, tick = Protocol.decodeMotion(payload)
	if not balls or tick < state.latestTick then
		return
	end
	if tick == state.latestTick then
		state.lastReceived = os.clock()
		return
	end
	state.latestTick = tick
	state.lastReceived = os.clock()
	table.insert(state.samples, { tick = tick, received = os.clock(), balls = balls })
	if #state.samples > 5 then
		table.remove(state.samples, 1)
	end
end
function Controller.positions(state: State, now: number): { Protocol.Motion }
	local samples = state.samples
	if #samples == 0 then
		return {}
	end
	local latest = samples[#samples]
	local target = latest.tick + math.min(now - latest.received, 0.25) * 60 - 6
	local first = latest
	local last = latest
	for i = 1, #samples - 1 do
		if samples[i].tick <= target and samples[i + 1].tick >= target then
			first = samples[i]
			last = samples[i + 1]
			break
		end
	end
	local result = {}
	for i, b in last.balls do
		local copy = table.clone(b)
		local a = first.balls[i]
		if a and first.tick ~= last.tick then
			local alpha = math.clamp((target - first.tick) / (last.tick - first.tick), 0, 1)
			copy.x = a.x + (b.x - a.x) * alpha
			copy.z = a.z + (b.z - a.z) * alpha
		elseif target > last.tick then
			local dt = math.min(0.15, (target - last.tick) / 60)
			copy.x = math.clamp(b.x + b.vx * dt, -Config.CenterBound, Config.CenterBound)
			copy.z = math.clamp(b.z + b.vz * dt, -Config.CenterBound, Config.CenterBound)
		end
		table.insert(result, copy)
	end
	return result
end
return table.freeze(Controller)
