--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local Config = require(Shared.Config)
local Geometry = require(Shared.Geometry2D)
local Types = require(Shared.Types)
export type State = {
	balls: { Types.Ball },
	tick: number,
	paths: { Types.Segment },
	capHits: number,
	recoveries: number,
}
type Contact = { a: number, b: number, axis: number }
local Sim = {}
function Sim.new(balls: { Types.Ball }): State
	return { balls = balls, tick = 0, paths = {}, capHits = 0, recoveries = 0 }
end
local function normalize(ball: Types.Ball)
	local length = math.sqrt(ball.vx ^ 2 + ball.vz ^ 2)
	if length > 1e-9 and length < math.huge then
		ball.vx = ball.vx / length * ball.speed
		ball.vz = ball.vz / length * ball.speed
		ball.lastDx = ball.vx / ball.speed
		ball.lastDz = ball.vz / ball.speed
	else
		-- A simultaneous impulse can cancel all velocity. Reverse the incoming
		-- direction so normalization cannot repeatedly re-enter that contact.
		ball.vx = -ball.lastDx * ball.speed
		ball.vz = -ball.lastDz * ball.speed
	end
end
local function separate(balls: { Types.Ball })
	for _ = 1, 4 do
		for i = 1, #balls do
			for j = i + 1, #balls do
				local a, b = balls[i], balls[j]
				local dx, dz = b.x - a.x, b.z - a.z
				local distance = math.sqrt(dx * dx + dz * dz)
				if distance < Config.Radius * 2 - 1e-8 then
					local nx, nz = 1, 0
					if distance > 1e-8 then
						nx, nz = dx / distance, dz / distance
					end
					local delta = (Config.Radius * 2 - distance) / 2 + 1e-7
					a.x -= nx * delta
					a.z -= nz * delta
					b.x += nx * delta
					b.z += nz * delta
				end
			end
		end
		for _, b in balls do
			b.x = math.clamp(b.x, -Config.CenterBound, Config.CenterBound)
			b.z = math.clamp(b.z, -Config.CenterBound, Config.CenterBound)
		end
	end
end
function Sim.step(state: State)
	state.tick += 1
	local balls: { Types.Ball } = {}
	for _, b in state.balls do
		if not b.weapon or b.weapon.hp > 0 then
			table.insert(balls, b)
		end
	end
	separate(balls)
	local remaining = 1 / 60
	local iterations = 0
	while remaining > 1e-10 do
		iterations += 1
		if iterations > Config.MaxCollisionIterations then
			state.capHits += 1
			-- Never advance through an unresolved contact or paint a fictitious chord.
			state.recoveries += 1
			separate(balls)
			break
		end
		local earliest = remaining
		local contacts: { Contact } = {}
		local function candidate(time: number?, contact: Contact)
			if time == nil then
				return
			end
			if time < earliest - 1e-8 then
				earliest = time
				table.clear(contacts)
			end
			if math.abs(time - earliest) <= 1e-8 then
				table.insert(contacts, contact)
			end
		end
		for i, a in balls do
			candidate(
				Geometry.sweepCircleWall(a.x, a.vx, Config.CenterBound, remaining),
				{ a = i, b = 0, axis = 1 }
			)
			candidate(
				Geometry.sweepCircleWall(a.z, a.vz, Config.CenterBound, remaining),
				{ a = i, b = 0, axis = 2 }
			)
			for j = i + 1, #balls do
				local b = balls[j]
				candidate(
					Geometry.sweepCircleCircle(
						b.x - a.x,
						b.z - a.z,
						b.vx - a.vx,
						b.vz - a.vz,
						Config.Radius * 2,
						remaining
					),
					{ a = i, b = j, axis = 0 }
				)
			end
		end
		for _, b in balls do
			local x, z = b.x, b.z
			b.x += b.vx * earliest
			b.z += b.vz * earliest
			table.insert(state.paths, {
				ax = x,
				az = z,
				bx = b.x,
				bz = b.z,
				team = b.team,
				radius = 0,
				ballId = b.id,
				t0 = 1 - remaining * 60,
				t1 = 1 - (remaining - earliest) * 60,
			})
		end
		remaining -= earliest
		if #contacts == 0 then
			break
		end
		local dvx, dvz = {}, {}
		for i = 1, #balls do
			dvx[i] = 0
			dvz[i] = 0
		end
		-- All impulses use velocities from before the simultaneous-contact batch.
		for _, contact in contacts do
			local a = balls[contact.a]
			if contact.b == 0 then
				if contact.axis == 1 then
					dvx[contact.a] -= 2 * a.vx
				else
					dvz[contact.a] -= 2 * a.vz
				end
			else
				local b = balls[contact.b]
				local dx, dz = b.x - a.x, b.z - a.z
				local length = math.sqrt(dx * dx + dz * dz)
				local nx, nz =
					if length > 1e-9 then dx / length else 1, if length > 1e-9 then dz / length else 0
				local relative = (b.vx - a.vx) * nx + (b.vz - a.vz) * nz
				if relative < 0 then
					dvx[contact.a] += relative * nx
					dvz[contact.a] += relative * nz
					dvx[contact.b] -= relative * nx
					dvz[contact.b] -= relative * nz
				end
			end
		end
		for i, b in balls do
			b.vx += dvx[i]
			b.vz += dvz[i]
			normalize(b)
		end
		-- Unequal nominal-speed normalization can turn a separating elastic
		-- contact into an approaching one. Project only that degenerate case
		-- onto a shared normal speed, retaining each kit's speed and tangent sign.
		-- This avoids infinitely repeated zero-time contacts without skipping time.
		for _, contact in contacts do
			if contact.b == 0 then
				continue
			end
			local a, b = balls[contact.a], balls[contact.b]
			local dx, dz = b.x - a.x, b.z - a.z
			local length = math.sqrt(dx * dx + dz * dz)
			if length < 1e-9 then
				continue
			end
			local nx, nz = dx / length, dz / length
			local an, bn = a.vx * nx + a.vz * nz, b.vx * nx + b.vz * nz
			if bn - an < -1e-9 then
				local shared =
					math.clamp((an + bn) / 2, -math.min(a.speed, b.speed), math.min(a.speed, b.speed))
				for _, ball in { a, b } do
					local tangent = -ball.vx * nz + ball.vz * nx
					local sign = if tangent < 0 then -1 else 1
					local speed = math.sqrt(math.max(0, ball.speed ^ 2 - shared ^ 2)) * sign
					ball.vx = shared * nx - speed * nz
					ball.vz = shared * nz + speed * nx
					ball.lastDx = ball.vx / ball.speed
					ball.lastDz = ball.vz / ball.speed
				end
			end
		end
		separate(balls)
	end
	for _, b in balls do
		assert(
			b.x == b.x
				and b.z == b.z
				and math.abs(b.x) <= Config.CenterBound + 0.00001
				and math.abs(b.z) <= Config.CenterBound + 0.00001,
			"Invalid simulation position"
		)
	end
end
return table.freeze(Sim)
