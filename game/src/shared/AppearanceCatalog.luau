--!strict
export type Appearance = { name: string, kit: string, description: string, color: Color3 }
local entries: { [string]: Appearance } = {
	Blade = {
		name = "Blade Ball",
		kit = "Anchor",
		description = "A sharp silhouette.\nHolds its path and\nclaims wider space.",
		color = Color3.fromRGB(63, 204, 244),
	},
	WDC = {
		name = "WDC",
		kit = "Drift",
		description = "A blue grid shell\nfor an expanding\nterritory pulse.",
		color = Color3.fromRGB(43, 105, 244),
	},
	Orbit = {
		name = "Orbit Ball",
		kit = "Drift",
		description = "A ringed shell\nthat sweeps across\nthe arena.",
		color = Color3.fromRGB(78, 206, 239),
	},
	Ray = {
		name = "Ray Ball",
		kit = "Drift",
		description = "A radiant shell\nfor claiming\nopen ground.",
		color = Color3.fromRGB(246, 173, 69),
	},
	Laser = {
		name = "Laser Ball",
		kit = "Drift",
		description = "A violet glow\nwith an expanding\nterritory pulse.",
		color = Color3.fromRGB(192, 71, 244),
	},
	Verity = {
		name = "Verity Ball",
		kit = "Drift",
		description = "A cheerful shell for claiming space.",
		color = Color3.fromRGB(255, 225, 0),
	},
	Burst = {
		name = "Burst Ball",
		kit = "Drift",
		description = "An orange burst shell for the Drift pulse.",
		color = Color3.fromRGB(255, 120, 0),
	},
	Vampire = {
		name = "Vampire Ball",
		kit = "Drift",
		description = "A red fanged shell for claiming space.",
		color = Color3.fromRGB(215, 22, 47),
	},
	Cell = {
		name = "Cell Ball",
		kit = "Drift",
		description = "Pulses outward,\nclaiming the space\naround it.",
		color = Color3.fromRGB(125, 226, 87),
	},
	Axe = {
		name = "Axe Ball",
		kit = "Anchor",
		description = "Spins an axe,\nwidening its\nterritory.",
		color = Color3.fromRGB(255, 156, 38),
	},
	Poison = {
		name = "Poison Spike Ball",
		kit = "Drift",
		description = "A bright poison\nshell with a\npowerful pulse.",
		color = Color3.fromRGB(89, 222, 0),
	},
	Acid = {
		name = "Acid Ball",
		kit = "Drift",
		description = "Leaves a vivid\ntrail as it\nclaims space.",
		color = Color3.fromRGB(91, 211, 15),
	},
}
for _, entry in entries do
	table.freeze(entry)
end
local Catalog = {
	entries = table.freeze(entries),
	ids = table.freeze({
		"Verity",
		"Axe",
		"Poison",
		"Burst",
		"Cell",
		"Vampire",
		"Acid",
		"Blade",
		"WDC",
		"Orbit",
		"Ray",
		"Laser",
	}),
}
function Catalog.default(kit: string): string
	return if kit == "Anchor" then "Axe" else "Acid"
end
function Catalog.valid(id: string?, kit: string): boolean
	local entry = if id then entries[id] else nil
	return entry ~= nil and entry.kit == kit
end
return table.freeze(Catalog)
