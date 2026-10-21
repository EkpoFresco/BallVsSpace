--!strict
local Shared = game:GetService("ReplicatedStorage").Shared
local Heroes = require(Shared.HeroDefinitions)
local Weapon = require(Shared.WeaponGeometry)
local Art = require(script.Parent.WeaponArt)
local Portrait = {}
function Portrait.draw(parent: GuiObject, id: string, withWeapon: boolean)
	local key = id .. tostring(withWeapon)
	if parent:GetAttribute("HeroPortraitKey") == key then
		return
	end
	parent:SetAttribute("HeroPortraitKey", key)
	local old = parent:FindFirstChild("HeroPortrait")
	if old then
		old:Destroy()
	end
	local hero = Heroes.heroes[id]
	if not hero then
		return
	end
	local root = Instance.new("Frame")
	root.Name = "HeroPortrait"
	root.BackgroundTransparency = 1
	root.Size = UDim2.fromScale(1, 1)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	local aspect = Instance.new("UIAspectRatioConstraint")
	aspect.AspectType = Enum.AspectType.FitWithinMaxSize
	aspect.Parent = root
	root.Parent = parent
	local scale, ox, oy = 0.86 / 6, 0.5, 0.5
	if withWeapon then
		local pose = Weapon.new(0, 0, -math.pi / 4)
		local edges = Weapon.sample(id, 0, 0, 1, pose, 60)
		local minX, maxX, minY, maxY = -3.3, 3.3, -3.3, 3.3
		for _, edge in edges do
			minX = math.min(minX, edge.ax - edge.radius, edge.bx - edge.radius)
			maxX = math.max(maxX, edge.ax + edge.radius, edge.bx + edge.radius)
			minY = math.min(minY, edge.az - edge.radius, edge.bz - edge.radius)
			maxY = math.max(maxY, edge.az + edge.radius, edge.bz + edge.radius)
		end
		scale = 0.88 / math.max(maxX - minX, maxY - minY)
		ox, oy = 0.5 - (minX + maxX) / 2 * scale, 0.5 - (minY + maxY) / 2 * scale
		Art.draw(Art.new(root, "Portrait"), id, 0, 0, pose.angle, edges, scale, ox, oy, false)
	end
	local shell = Art.image(root, "Shell", "Body")
	shell.Position = UDim2.fromScale(ox, oy)
	shell.Size = UDim2.fromScale(6 * scale, 6 * scale)
	shell.ImageColor3 = hero.color
	shell.ZIndex = 3
	local glint = Art.image(root, "Highlight", "Glint")
	glint.Position = shell.Position
	glint.Size = shell.Size
	glint.ImageTransparency = 0.35
	glint.ZIndex = 4
	parent:SetAttribute("HeroId", id)
end
return table.freeze(Portrait)
