--!strict
local Heroes = require(game:GetService("ReplicatedStorage").Shared.HeroDefinitions)
local Portrait = require(script.Parent.HeroPortrait)
local Art = {}
function Art.build(parent: Instance, skin: string): Model
	local model = Instance.new("Model")
	model.Name = "HeroModel"
	local hero = Heroes.heroes[skin]
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Shape = Enum.PartType.Ball
	body.Size = Vector3.new(2, 2, 2)
	body.Color = if hero then hero.color else Color3.fromRGB(90, 100, 120)
	body.Anchored = true
	body.CanCollide = false
	body.Parent = model
	model.PrimaryPart = body
	model.Parent = parent
	model:SetAttribute("OriginalHero", skin)
	return model
end
function Art.setSkin(viewport: ViewportFrame, skin: string)
	viewport:SetAttribute("SpriteSkin", skin)
	viewport.ImageTransparency = 1
	Portrait.draw(viewport, skin, viewport:GetAttribute("BodyOnly") ~= true)
	local portrait = viewport:FindFirstChild("HeroPortrait")
	if portrait and portrait:IsA("GuiObject") then
		portrait.Visible = skin ~= ""
	end
	local unknown = viewport:FindFirstChild("Unknown")
	if unknown and unknown:IsA("TextLabel") then
		unknown.Visible = skin == ""
	end
end
function Art.animate(viewport: ViewportFrame, rotation: number, _weaponAngle: number, _weaponVisible: boolean)
	local portrait = viewport:FindFirstChild("HeroPortrait")
	if portrait and portrait:IsA("GuiObject") then
		portrait.Rotation = rotation
	end
end
function Art.viewport(parent: Instance, name: string, skin: string): (ViewportFrame, Model)
	local v = Instance.new("ViewportFrame")
	v.Name = name
	v.BackgroundTransparency = 1
	local world = Instance.new("WorldModel")
	world.Parent = v
	local model = Art.build(world, skin)
	local camera = Instance.new("Camera")
	camera.FieldOfView = 30
	camera.CFrame = CFrame.new(0, 0, 6)
	camera.Parent = v
	v.CurrentCamera = camera
	local unknown = Instance.new("TextLabel")
	unknown.Name = "Unknown"
	unknown.Size = UDim2.fromScale(1, 1)
	unknown.BackgroundTransparency = 1
	unknown.Text = "?"
	unknown.TextScaled = true
	unknown.TextColor3 = Color3.fromRGB(255, 239, 189)
	unknown.Parent = v
	Art.setSkin(v, skin)
	v.Parent = parent
	return v, model
end
return table.freeze(Art)
