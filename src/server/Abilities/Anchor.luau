--!strict
local Types = require(game:GetService("ReplicatedStorage").Shared.Types)
local Anchor = {}
function Anchor.beforeStep(tick: number, ball: Types.Ball)
	if tick == ball.nextAbilityTick then
		ball.nextAbilityTick += 480
		ball.effectEndTick = tick + 120
	end
	ball.brush = if tick < ball.effectEndTick then 7 else 4.5
end
return table.freeze(Anchor)
