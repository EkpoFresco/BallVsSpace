--!strict
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local Detail = require(script.Parent.LobbyDetailService)
local World = {}
function World.build()
	local old = Workspace:FindFirstChild("BVSCourt")
	if old then
		old:Destroy()
	end
	local root = Instance.new("Folder")
	root.Name = "BVSCourt"
	local function part(name: string, size: Vector3, position: Vector3, color: Color3, neon: boolean?): Part
		local p = Instance.new("Part")
		p.Name = name
		p.Anchored = true
		p.Size = size
		p.Position = position
		p.Color = color
		p.Material = if neon then Enum.Material.Neon else Enum.Material.SmoothPlastic
		p.TopSurface = Enum.SurfaceType.Smooth
		p.BottomSurface = Enum.SurfaceType.Smooth
		p.Parent = root
		return p
	end
	part("BluePlaza", Vector3.new(520, 3, 800), Vector3.new(0, -2, 80), Color3.fromRGB(40, 105, 175))
	part("MainWalkway", Vector3.new(42, 0.2, 330), Vector3.new(0, -0.35, -15), Color3.fromRGB(24, 55, 99))
	for _, x in { -23, 23 } do
		part(
			"WalkwayTrim",
			Vector3.new(0.4, 0.25, 330),
			Vector3.new(x, -0.25, -15),
			Color3.fromRGB(71, 163, 224)
		)
	end
	for row = 1, 4 do
		local z = 145 - row * 65
		part("Crosswalk", Vector3.new(330, 0.2, 6), Vector3.new(0, -0.3, z), Color3.fromRGB(26, 63, 110))
		for _, side in { -1, 1 } do
			local x = side * 90
			part("ArenaPodium", Vector3.new(78, 2, 49), Vector3.new(x, 0.5, z), Color3.fromRGB(18, 44, 83))
			part("ArenaInset", Vector3.new(70, 0.3, 41), Vector3.new(x, 1.7, z), Color3.fromRGB(38, 86, 143))
			for _, offset in { -38, 38 } do
				part(
					"ArenaLight",
					Vector3.new(0.3, 0.2, 49),
					Vector3.new(x + offset, 1.8, z),
					Color3.fromRGB(57, 170, 240),
					true
				)
			end
		end
	end
	local function sign(p: BasePart, text: string, color: Color3)
		local g = Instance.new("SurfaceGui")
		g.Face = Enum.NormalId.Front
		g.CanvasSize = Vector2.new(700, 300)
		g.Parent = p
		local t = Instance.new("TextLabel")
		t.Size = UDim2.fromScale(1, 1)
		t.BackgroundTransparency = 1
		t.Text = text
		t.Font = Enum.Font.GothamBlack
		t.TextScaled = true
		t.TextWrapped = true
		t.TextColor3 = color
		t.TextStrokeTransparency = 0
		t.Parent = g
	end
	for i, x in { -9, 32 } do
		local z = if i == 1 then 169 else 140
		part("DisplayPlinth", Vector3.new(10, 1, 9), Vector3.new(x, 0.4, z), Color3.fromRGB(25, 53, 93))
		part("ConsoleBase", Vector3.new(6, 3, 5), Vector3.new(x, 2, z), Color3.fromRGB(164, 192, 215))
		local monitor =
			part("Display", Vector3.new(6.6, 5.5, 1.1), Vector3.new(x, 6.2, z), Color3.fromRGB(91, 130, 166))
		local panel = part(
			"DisplayGlass",
			Vector3.new(5.3, 4.4, 0.2),
			Vector3.new(x, 6.2, z + 0.7),
			Color3.fromRGB(33, 50, 83)
		)
		monitor.Orientation = Vector3.new(0, 180, 0)
		panel.Orientation = monitor.Orientation
		local ball = part(
			"ShowcaseBall",
			Vector3.new(2.7, 2.7, 2.7),
			Vector3.new(x, 6.2, z + 1.1),
			if i == 1 then Color3.fromRGB(255, 161, 16) else Color3.fromRGB(96, 233, 25),
			true
		)
		ball.Shape = Enum.PartType.Ball
		local banner =
			part("Banner", Vector3.new(18, 3, 0.3), Vector3.new(x, 10.5, z), Color3.fromRGB(22, 48, 81))
		banner.Orientation = Vector3.new(0, 180, 0)
		banner.Transparency = 1
		banner.CanCollide = false
		local billboard = Instance.new("BillboardGui")
		billboard.Name = "FloatingSign"
		billboard.Size = UDim2.fromOffset(310, 58)
		billboard.AlwaysOnTop = false
		billboard.MaxDistance = 100
		billboard.Parent = banner
		local caption = Instance.new("TextLabel")
		caption.Size = UDim2.fromScale(1, 1)
		caption.BackgroundTransparency = 1
		caption.Font = Enum.Font.GothamBlack
		caption.TextSize = 22
		caption.Text = if i == 1
			then "All Balls Free\nChoose Your Favorite"
			else "BALL VS SPACE\nPick · Aim · Play"
		caption.TextColor3 = Color3.fromRGB(255, 197, 38)
		caption.TextStrokeTransparency = 0
		caption.Parent = billboard
		local slot = part(
			"ConsoleSlot",
			Vector3.new(2.1, 0.55, 0.15),
			Vector3.new(x, 2.3, z + 2.55),
			Color3.fromRGB(47, 71, 99)
		)
		slot.CanCollide = false
	end
	local blob = part(
		"PurpleLobbyOrb",
		Vector3.new(4.8, 2.4, 4),
		Vector3.new(11, 1.0, 186),
		Color3.fromRGB(105, 91, 181)
	)
	blob.Shape = Enum.PartType.Ball
	local topBlob = part(
		"OrbHighlight",
		Vector3.new(2.5, 2.8, 2.3),
		Vector3.new(10.5, 1.3, 185.4),
		Color3.fromRGB(112, 101, 194)
	)
	topBlob.Shape = Enum.PartType.Ball
	for _, x in { -50, 50 } do
		local p = part(
			"ModePortal",
			Vector3.new(11, 18, 2),
			Vector3.new(x, 8, 95),
			Color3.fromRGB(73, 72, 230),
			true
		)
		p.Orientation = Vector3.new(0, 180, 0)
		sign(p, if x < 0 then "1V1\nDUELS" else "PRACTICE", Color3.new(1, 1, 1))
	end
	for i = 1, 6 do
		local x = if i % 2 == 0 then 142 else -142
		local p = part(
			"Leaderboard",
			Vector3.new(20, 32, 2),
			Vector3.new(x, 15, 90 - i * 25),
			Color3.fromRGB(22, 35, 114)
		)
		p.Orientation = Vector3.new(0, if x > 0 then 135 else 225, 0)
		sign(p, "BALL VS SPACE\nTHE ARENA", Color3.fromRGB(134, 197, 255))
	end
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "LobbySpawn"
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.CFrame = CFrame.new(0, 0, 190)
	spawn.Transparency = 1
	spawn.Anchored = true
	spawn.CanCollide = false
	spawn.Neutral = true
	spawn.Duration = 0
	spawn.Parent = root
	root.Parent = Workspace
	Lighting.ClockTime = 14
	Lighting.Brightness = 2
	Lighting.ExposureCompensation = 0
	Lighting.Ambient = Color3.fromRGB(130, 145, 170)
	Lighting.OutdoorAmbient = Color3.fromRGB(150, 160, 180)
	Lighting.FogStart = 800
	Lighting.FogEnd = 4000
	if not Lighting:FindFirstChildOfClass("Sky") then
		Instance.new("Sky").Parent = Lighting
	end
	local clouds = Workspace.Terrain:FindFirstChildOfClass("Clouds")
	if not clouds then
		clouds = Instance.new("Clouds")
		clouds.Parent = Workspace.Terrain
	end
	clouds.Cover = 0.5
	clouds.Density = 0.65
	clouds.Color = Color3.fromRGB(250, 254, 255)
	for _, name in { "Baseplate", "SpawnLocation" } do
		local item = Workspace:FindFirstChild(name)
		if item then
			item:Destroy()
		end
	end
	Detail.build(root)
end
return table.freeze(World)
