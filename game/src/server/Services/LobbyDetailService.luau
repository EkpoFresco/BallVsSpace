--!strict
-- Original authored environment details. Prompts route through the normal client commands.
local Lighting = game:GetService("Lighting")
local Detail = {}
local navy = Color3.fromRGB(17, 35, 61)
local cyan = Color3.fromRGB(111, 226, 255)
local function part(
	parent: Instance,
	name: string,
	position: Vector3,
	size: Vector3,
	color: Color3,
	material: Enum.Material?
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Position = position
	p.Size = size
	p.Color = color
	p.Anchored = true
	p.Material = material or Enum.Material.SmoothPlastic
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end
local function label(
	parent: Instance,
	text: string,
	y: number,
	height: number,
	size: number,
	color: Color3
): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, -20, 0, height)
	t.Position = UDim2.fromOffset(10, y)
	t.Text = text
	t.TextColor3 = color
	t.FontFace = Font.new("rbxasset://fonts/families/Michroma.json")
	t.TextSize = size
	t.TextStrokeTransparency = 0
	t.TextWrapped = true
	t.Parent = parent
	return t
end
local function prompt(parent: BasePart, action: string, title: string)
	local p = Instance.new("ProximityPrompt")
	p.Name = "BVSInteract"
	p.ActionText = title
	p.ObjectText = "Ball VS Space"
	p.MaxActivationDistance = 13
	p.RequiresLineOfSight = false
	p:SetAttribute("BVSAction", action)
	p.Parent = parent
end
local function sign(parent: BasePart, text: string, width: number, height: number): BillboardGui
	local g = Instance.new("BillboardGui")
	g.Name = "ArenaSign"
	g.Size = UDim2.fromScale(width / 18, height / 18)
	g.AlwaysOnTop = false
	g.MaxDistance = 150
	g.Parent = parent
	label(g, text, 0, height, 22, Color3.new(1, 1, 1))
	return g
end
function Detail.build(root: Folder)
	local plaza = root:FindFirstChild("BluePlaza") :: BasePart
	plaza.Material = Enum.Material.SmoothPlastic
	plaza.Color = Color3.fromRGB(42, 88, 137)
	local walkway = root:FindFirstChild("MainWalkway") :: BasePart
	walkway.Color = Color3.fromRGB(25, 49, 80)
	-- Subtle paving and painted lane edges give the blue plaza depth at ground level.
	for i = 0, 12 do
		local z = 201 - i * 30
		for _, x in { -19, 19 } do
			part(
				root,
				"LaneDash",
				Vector3.new(x, -0.19, z),
				Vector3.new(0.3, 0.03, 11),
				Color3.fromRGB(99, 146, 181)
			)
		end
		for _, x in { -39, 39 } do
			part(
				root,
				"PavingJoint",
				Vector3.new(x, -0.47, z),
				Vector3.new(28, 0.02, 0.08),
				Color3.fromRGB(35, 73, 115)
			)
		end
	end
	for _, item in root:GetChildren() do
		if item.Name == "ShowcaseBall" and item:IsA("BasePart") then
			item.Material = Enum.Material.SmoothPlastic
			item.Transparency = 1
			item.CanCollide = false
		elseif item.Name == "DisplayGlass" and item:IsA("BasePart") then
			local g = Instance.new("SurfaceGui")
			g.Name = "CollectionDisplay"
			g.Face = Enum.NormalId.Front
			g.CanvasSize = Vector2.new(256, 256)
			g.Parent = item
			local image = Instance.new("ImageLabel")
			image.BackgroundTransparency = 1
			image.Size = UDim2.fromScale(1, 1)
			image.Image = "rbxassetid://132245039697166"
			image.ImageRectOffset =
				Vector2.new(if item.Position.X < 0 then 768 else 512, if item.Position.X < 0 then 0 else 256)
			image.ImageRectSize = Vector2.new(256, 256)
			image.Parent = g
		elseif item.Name == "ConsoleBase" and item:IsA("BasePart") then
			local pos = item.Position
			for _, dx in { -2.5, 2.5 } do
				part(
					root,
					"ConsoleFoot",
					Vector3.new(pos.X + dx, 0.9, pos.Z + 1.2),
					Vector3.new(1.4, 1.6, 3.7),
					Color3.fromRGB(176, 191, 207)
				)
			end
			local button = part(
				root,
				"ConsoleButton",
				Vector3.new(pos.X + 0.4, 3.55, pos.Z + 2.1),
				Vector3.new(0.6, 0.15, 0.6),
				Color3.fromRGB(219, 41, 77),
				Enum.Material.Neon
			)
			button.Shape = Enum.PartType.Cylinder
			prompt(
				item,
				if pos.X < 0 then "Store" else "Inventory",
				if pos.X < 0 then "Browse Balls" else "Open Collection"
			)
		elseif item.Name == "Banner" and item:IsA("BasePart") then
			local g = item:FindFirstChild("FloatingSign")
			if g then
				local t = g:FindFirstChildOfClass("TextLabel")
				if t then
					t.FontFace = Font.new("rbxasset://fonts/families/Michroma.json")
					t.TextSize = 19
					t.Text = if item.Position.X < 0
						then "Choose + Play\nFind Your Favorite Ball"
						else "Free Collection\nEvery Ball, Your Choice"
				end
			end
		elseif item.Name == "Leaderboard" and item:IsA("BasePart") then
			item.Color = Color3.fromRGB(13, 24, 59)
			local g = item:FindFirstChildOfClass("SurfaceGui")
			if g then
				g:ClearAllChildren()
				g.CanvasSize = Vector2.new(500, 740)
				label(g, "THE ARENA", 8, 72, 40, Color3.new(1, 1, 1))
				label(g, "CLAIM YOUR SPACE", 78, 45, 22, Color3.fromRGB(173, 221, 255))
				for i = 1, 7 do
					local row = Instance.new("Frame")
					row.Size = UDim2.fromOffset(470, 70)
					row.Position = UDim2.fromOffset(15, 135 + (i - 1) * 81)
					row.BorderSizePixel = 0
					row.BackgroundColor3 = if i == 1
						then Color3.fromRGB(210, 153, 21)
						elseif i % 2 == 0 then Color3.fromRGB(50, 61, 167)
						else Color3.fromRGB(30, 39, 123)
					row.Parent = g
					local steps = {
						"CHOOSE YOUR BALL",
						"SET YOUR AIM",
						"PAINT THE ARENA",
						"REINFORCE YOUR TRAIL",
						"TURN THE TIDE",
						"WIN THE ROUND",
						"PLAY AGAIN",
					}
					label(row, tostring(i) .. "     " .. steps[i], 0, 70, 19, Color3.new(1, 1, 1))
				end
			end
		elseif item.Name == "ArenaPodium" and item:IsA("BasePart") then
			local pos = item.Position
			-- Physical queue pads, framed court and side displays match the lobby's arena rhythm.
			for seat = 1, 2 do
				local x = pos.X + (if seat == 1 then -27 else 27)
				local pad =
					part(root, "QueuePad", Vector3.new(x, 1.7, pos.Z + 14), Vector3.new(12, 0.2, 11), navy)
				for _, dx in { -6, 6 } do
					part(
						root,
						"PadEdge",
						pad.Position + Vector3.new(dx, 0.15, 0),
						Vector3.new(0.27, 0.2, 11),
						if seat == 1 then cyan else Color3.fromRGB(255, 186, 184),
						Enum.Material.Neon
					)
				end
				for _, dz in { -5.5, 5.5 } do
					part(
						root,
						"PadEdge",
						pad.Position + Vector3.new(0, 0.15, dz),
						Vector3.new(12, 0.2, 0.27),
						if seat == 1 then cyan else Color3.fromRGB(255, 186, 184),
						Enum.Material.Neon
					)
				end
				prompt(pad, "Play", "Join Duel")
			end
			local anchor = part(root, "QueueSign", pos + Vector3.new(0, 6, 12), Vector3.new(1, 1, 1), navy)
			anchor.Transparency = 1
			anchor.CanCollide = false
			sign(anchor, "1V1 DUEL\nCLAIM THE MOST SPACE", 260, 54)
			for _, dx in { -18, 18 } do
				part(root, "CourtBorder", pos + Vector3.new(dx, 1.7, -7), Vector3.new(1.1, 1.7, 27), navy)
			end
			for _, dz in { -20.5, 6.5 } do
				part(root, "CourtBorder", pos + Vector3.new(0, 1.7, dz), Vector3.new(37, 1.7, 1.1), navy)
			end
			part(
				root,
				"CourtFloor",
				pos + Vector3.new(0, 1, -7),
				Vector3.new(35, 0.15, 26),
				Color3.fromRGB(24, 43, 73)
			)
		end
	end
	-- Portal pillars, circular pads, and soft blue light replace the plain sign slabs.
	for _, old in root:GetChildren() do
		if old.Name == "ModePortal" then
			old:Destroy()
		end
	end
	for _, x in { -50, 50 } do
		local z = 95
		local base = part(root, "PortalBase", Vector3.new(x, 0, z), Vector3.new(1.2, 19, 19), navy)
		base.Shape = Enum.PartType.Cylinder
		base.Orientation = Vector3.new(0, 0, 90)
		local inset = part(
			root,
			"PortalGlow",
			Vector3.new(x, 0.7, z),
			Vector3.new(0.25, 15, 15),
			cyan,
			Enum.Material.Neon
		)
		inset.Shape = Enum.PartType.Cylinder
		inset.Orientation = Vector3.new(0, 0, 90)
		for _, dx in { -8, 8 } do
			part(
				root,
				"PortalPillar",
				Vector3.new(x + dx, 8, z),
				Vector3.new(1.1, 16, 1.3),
				Color3.fromRGB(33, 68, 105)
			)
			part(
				root,
				"PortalLight",
				Vector3.new(x + dx, 8, z + 0.72),
				Vector3.new(0.4, 15, 0.15),
				cyan,
				Enum.Material.Neon
			)
		end
		local field = part(
			root,
			"PortalField",
			Vector3.new(x, 8, z),
			Vector3.new(14, 14, 0.3),
			Color3.fromRGB(169, 243, 255),
			Enum.Material.Neon
		)
		field.Transparency = 0.75
		field.CanCollide = false
		local light = Instance.new("PointLight")
		light.Color = cyan
		light.Range = 21
		light.Brightness = 1.2
		light.Parent = field
		local header = part(root, "PortalHeader", Vector3.new(x, 19, z), Vector3.one, navy)
		header.Transparency = 1
		header.CanCollide = false
		sign(header, if x < 0 then "1V1" else "PRACTICE", 170, 50)
		prompt(field, if x < 0 then "Play" else "Practice", if x < 0 then "Choose Mode" else "Start Practice")
	end
	local blob = root:FindFirstChild("PurpleLobbyOrb") :: BasePart
	blob.Size = Vector3.new(5.3, 2.4, 3.8)
	blob.Color = Color3.fromRGB(111, 98, 174)
	blob.Orientation = Vector3.new(0, -20, -8)
	local cap = root:FindFirstChild("OrbHighlight") :: BasePart
	cap.Size = Vector3.new(2.9, 2.4, 3.2)
	cap.Position = Vector3.new(10.3, 1.5, 186)
	cap.Color = blob.Color
	Lighting.ClockTime = 13.6
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(95, 116, 146)
	Lighting.OutdoorAmbient = Color3.fromRGB(128, 145, 166)
	Lighting.FogColor = Color3.fromRGB(117, 191, 231)
	Lighting.FogStart = 300
	Lighting.FogEnd = 1350
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
	atmosphere.Density = 0.18
	atmosphere.Offset = 0.1
	atmosphere.Color = Color3.fromRGB(190, 220, 245)
	atmosphere.Decay = Color3.fromRGB(122, 168, 210)
	atmosphere.Haze = 0.3
	atmosphere.Parent = Lighting
end
return table.freeze(Detail)
