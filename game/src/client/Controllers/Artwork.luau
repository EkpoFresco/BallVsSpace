--!strict
-- Original SVG sources and the reproducible atlas builder live in game/tools/art.
-- The published icon atlas belongs to this project; heroes use the original flat weapon atlas.
local Artwork = {}
local Heroes = require(game:GetService("ReplicatedStorage").Shared.HeroDefinitions)
local Portrait = require(script.Parent.HeroPortrait)
local WeaponArt = require(script.Parent.WeaponArt)
Artwork.iconAsset = "rbxassetid://90376324892151"
Artwork.studAsset = "rbxassetid://77193408549941"
function Artwork.preload()
	local ok, message = pcall(function()
		game:GetService("ContentProvider")
			:PreloadAsync({ Artwork.iconAsset, Artwork.studAsset, WeaponArt.asset })
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
local iconIndex: { [string]: number } = {}
for i, id in icons do
	iconIndex[id] = i - 1
end
function Artwork.set(image: ImageLabel, id: string, _ball: boolean?)
	if Heroes.heroes[id] then
		image.Image = ""
		image.ImageRectOffset = Vector2.zero
		image.ImageRectSize = Vector2.zero
		Portrait.draw(image, id, true)
		image:SetAttribute("ArtworkId", id)
		return
	end
	local old = image:FindFirstChild("HeroPortrait")
	if old then
		old:Destroy()
	end
	image:SetAttribute("HeroPortraitKey", nil)
	local index = iconIndex[id]
	assert(index, "Unknown authored image: " .. id)
	local size = 128
	local columns = 8
	image.Image = Artwork.iconAsset
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
	return frame
end
return table.freeze(Artwork)
