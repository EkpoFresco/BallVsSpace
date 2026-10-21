--!strict
local Heroes = require(script.Parent.HeroDefinitions)
export type Appearance = { name: string, kit: string, description: string, color: Color3 }
local entries: { [string]: Appearance } = {}
for _, id in Heroes.ids do
	local h = Heroes.heroes[id]
	entries[id] = table.freeze({
		name = id .. " " .. h.title,
		kit = id,
		description = h.weapon .. ". " .. h.ability,
		color = h.color,
	})
end
local Catalog = { entries = table.freeze(entries), ids = Heroes.ids }
function Catalog.default(kit: string): string
	return if entries[kit] then kit else "Astra"
end
function Catalog.valid(id: string?, kit: string): boolean
	return id ~= nil and entries[id] ~= nil and id == kit
end
return table.freeze(Catalog)
