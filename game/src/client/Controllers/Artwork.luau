--!strict
-- Original SVG sources and the reproducible atlas builder live in game/tools/art.
-- These two published images belong to this project; no reference pixels are embedded.
local Artwork = {}
function Artwork.preload()
	local ok, message = pcall(function()
		game:GetService("ContentProvider")
			:PreloadAsync({ "rbxassetid://132245039697166", "rbxassetid://105537358583136" })
	end)
	if not ok then
		warn("BVS artwork preload: " .. tostring(message))
	end
end
local icons = {
	"Heart",
	"Gear",
	"Coin",
	"Gem",
	"Store",
	"Inventory",
	"Emote",
	"Gift",
	"Invite",
	"Trade",
	"Quest",
	"Reroll",
	"Crown",
	"Close",
	"Help",
	"Chat",
	"Events",
	"Fusion",
	"Axe",
	"Blade",
	"Ufo",
	"Explosion",
	"Parasol",
	"Balloons",
	"Check",
	"Back",
	"Arrow",
	"Sound",
	"Diamond",
	"Ring",
	"Spark",
	"Shadow",
}
local balls =
	{ "Verity", "Axe", "Poison", "Burst", "Cell", "Vampire", "Acid", "Blade", "WDC", "Orbit", "Ray", "Laser" }
local iconIndex: { [string]: number } = {}
local ballIndex: { [string]: number } = {}
for i, id in icons do
	iconIndex[id] = i - 1
end
for i, id in balls do
	ballIndex[id] = i - 1
end
function Artwork.set(image: ImageLabel, id: string, ball: boolean?)
	local index = (if ball then ballIndex else iconIndex)[id]
	assert(index, "Unknown authored image: " .. id)
	local size = if ball then 256 else 128
	local columns = if ball then 4 else 8
	image.Image = if ball then "rbxassetid://132245039697166" else "rbxassetid://105537358583136"
	image.ImageRectOffset = Vector2.new(index % columns * size, (index // columns) * size)
	image.ImageRectSize = Vector2.new(size, size)
	image:SetAttribute("ArtworkId", id)
end
function Artwork.image(
	parent: Instance,
	name: string,
	id: string,
	x: number,
	y: number,
	w: number,
	h: number,
	ball: boolean?
): ImageLabel
	local image = Instance.new("ImageLabel")
	image.Name = name
	image.BackgroundTransparency = 1
	image.Position = UDim2.fromOffset(x, y)
	image.Size = UDim2.fromOffset(w, h)
	image.ScaleType = Enum.ScaleType.Fit
	Artwork.set(image, id, ball)
	image.Parent = parent
	return image
end
function Artwork.portrait(parent: Instance, id: string, x: number, y: number, size: number): Frame
	local frame = Instance.new("Frame")
	frame.Name = "PortraitArt"
	frame.BackgroundTransparency = 1
	frame.Position = UDim2.fromOffset(x, y)
	frame.Size = UDim2.fromOffset(size, size)
	frame.Parent = parent
	Artwork.image(frame, "Ball", id, 0, 0, size, size, true)
	if id == "Axe" or id == "Blade" then
		Artwork.image(frame, "Weapon", id, size * 0.31, -size * 0.16, size * 0.4, size * 0.67)
	end
	return frame
end
return table.freeze(Artwork)
