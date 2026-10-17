--!strict
local Types = require(game:GetService("ReplicatedStorage").Shared.Types)
local Drift = {}
function Drift.step(tick: number, ball: Types.Ball): Types.Shape?
	if tick ~= ball.nextAbilityTick then
		return nil
	end
	ball.nextAbilityTick += 360
	return { ax = ball.x, az = ball.z, bx = ball.x, bz = ball.z, radius = 6, team = ball.team, strength = 2 }
end
return table.freeze(Drift)
