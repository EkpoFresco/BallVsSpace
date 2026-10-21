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
		local latest = state.samples[#state.samples]
		if latest then
			latest.balls = balls
		end
		return
	end
	state.latestTick = tick
	state.lastReceived = os.clock()
	table.insert(state.samples, { tick = tick, received = os.clock(), balls = balls })
	if #state.samples > 5 then
		table.remove(state.samples, 1)
	end
end
function Controller.interpolate(
	first: { Protocol.Motion },
	last: { Protocol.Motion },
	alpha: number
): { Protocol.Motion }
	local result = {}
	for i, b in last do
		local copy = table.clone(b)
		copy.weapon = table.clone(b.weapon)
		local a = first[i]
		if a and a.id == b.id then
			copy.x = a.x + (b.x - a.x) * alpha
			copy.z = a.z + (b.z - a.z) * alpha
			copy.weapon.angle = a.weapon.angle + (b.weapon.angle - a.weapon.angle) * alpha
			copy.weapon.spin = a.weapon.spin + (b.weapon.spin - a.weapon.spin) * alpha
		end
		table.insert(result, copy)
	end
	return result
end
function Controller.positions(state: State, now: number): ({ Protocol.Motion }, number)
	local samples = state.samples
	if #samples == 0 then
		return {}, 0
	end
	local latest = samples[#samples]
	-- Geometry and angles share this fractional clock. A 10 Hz territory tick
	-- makes whips and projectiles visibly step even when the ball is interpolated.
	local target =
		math.clamp(latest.tick + (now - latest.received) * 60 - 6, samples[1].tick, latest.tick + 6)
	local first = latest
	local last = latest
	if target <= samples[1].tick then
		first = samples[1]
		last = samples[1]
	end
	for i = 1, #samples - 1 do
		if samples[i].tick <= target and samples[i + 1].tick >= target then
			first = samples[i]
			last = samples[i + 1]
			break
		end
	end
	local alpha = if first.tick ~= last.tick then (target - first.tick) / (last.tick - first.tick) else 1
	local result = Controller.interpolate(first.balls, last.balls, math.clamp(alpha, 0, 1))
	if target > last.tick then
		for i, copy in result do
			local b = last.balls[i]
			local dt = math.min(0.10, (target - last.tick) / 60)
			copy.weapon.angle += b.weapon.omega * dt
			copy.weapon.spin += math.abs(b.weapon.omega) * dt
			copy.x = math.clamp(b.x + b.vx * dt, -Config.CenterBound, Config.CenterBound)
			copy.z = math.clamp(b.z + b.vz * dt, -Config.CenterBound, Config.CenterBound)
		end
	end
	return result, target
end
return table.freeze(Controller)
