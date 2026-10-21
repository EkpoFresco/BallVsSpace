--!strict
local Heroes = require(script.Parent.HeroDefinitions)
export type Kit = {
	id: string,
	speed: number,
	brushRadius: number,
	firstReadyTick: number,
	cooldownTicks: number,
	durationTicks: number,
	previewSeconds: number,
	role: string,
	description: string,
}
local kits: { [string]: Kit } = {}
for _, id in Heroes.ids do
	local hero = Heroes.heroes[id]
	kits[id] = table.freeze({
		id = id,
		speed = 18,
		brushRadius = 0,
		firstReadyTick = 240,
		cooldownTicks = 240,
		durationTicks = 120,
		previewSeconds = 0.5,
		role = hero.family,
		description = hero.ability,
	})
end
return table.freeze({ kits = table.freeze(kits), ids = Heroes.ids })
