--!strict
local Types = require(game:GetService("ReplicatedStorage").Shared.Types)
local Anchor = require(script.Parent.Parent.Abilities.Anchor)
local Drift = require(script.Parent.Parent.Abilities.Drift)
local Ability = {}
function Ability.beforeStep(tick: number, balls: { Types.Ball })
	for _, ball in balls do
		if ball.kitId == "Anchor" then
			Anchor.beforeStep(tick, ball)
		end
	end
end
function Ability.afterStep(tick: number, balls: { Types.Ball }, effects: { Types.Shape })
	for _, ball in balls do
		if ball.kitId == "Drift" then
			local shape = Drift.step(tick, ball)
			if shape then
				table.insert(effects, shape)
			end
		end
	end
	assert(#effects <= #balls * 8, "Ability shape budget exceeded")
end
return table.freeze(Ability)
