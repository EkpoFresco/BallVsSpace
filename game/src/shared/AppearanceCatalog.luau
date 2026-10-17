--!strict
export type Appearance = { name: string, kit: string, description: string, color: Color3 }
local entries: { [string]: Appearance } = {
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
	ids = table.freeze({ "Verity", "Axe", "Poison", "Burst", "Cell", "Vampire", "Acid" }),
}
function Catalog.default(kit: string): string
	return if kit == "Anchor" then "Axe" else "Acid"
end
function Catalog.valid(id: string?, kit: string): boolean
	local entry = if id then entries[id] else nil
	return entry ~= nil and entry.kit == kit
end
return table.freeze(Catalog)
