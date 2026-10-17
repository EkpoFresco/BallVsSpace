--!strict
local Art = {}
local function piece(
	root: Instance,
	name: string,
	size: Vector3,
	cf: CFrame,
	color: Color3,
	ball: boolean?
): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = Enum.Material.SmoothPlastic
	if ball then
		p.Shape = Enum.PartType.Ball
	end
	p.Parent = root
	return p
end
function Art.build(parent: Instance, skin: string): Model
	local m = Instance.new("Model")
	m.Name = skin
	local color = if skin == "Axe"
		then Color3.fromRGB(37, 47, 70)
		elseif skin == "Cell" then Color3.fromRGB(117, 212, 94)
		elseif skin == "Acid" then Color3.fromRGB(79, 192, 0)
		elseif skin == "Verity" then Color3.fromRGB(255, 225, 0)
		elseif skin == "Burst" then Color3.fromRGB(255, 120, 0)
		elseif skin == "Vampire" then Color3.fromRGB(215, 22, 47)
		else Color3.fromRGB(85, 213, 0)
	local body = piece(m, "Body", Vector3.new(2, 2, 2), CFrame.identity, color, true)
	m.PrimaryPart = body
	if skin == "Verity" then
		for _, x in { -0.32, 0.32 } do
			piece(
				m,
				"Eye",
				Vector3.new(0.16, 0.28, 0.06),
				CFrame.new(x, 0.28, 0.94),
				Color3.fromRGB(26, 28, 7),
				true
			)
		end
		for i = 0, 10 do
			local a = math.rad(205 + i * 13)
			local x, y = math.cos(a) * 0.55, math.sin(a) * 0.55
			piece(
				m,
				"Smile",
				Vector3.new(0.17, 0.14, 0.06),
				CFrame.new(x, y, math.sqrt(1 - x * x - y * y) + 0.03) * CFrame.Angles(0, 0, a + math.pi / 2),
				Color3.fromRGB(26, 28, 7),
				true
			)
		end
	elseif skin == "Burst" then
		piece(
			m,
			"CrossHorizontal",
			Vector3.new(1.1, 0.34, 0.05),
			CFrame.new(0, 0, 0.99),
			Color3.fromRGB(255, 239, 135)
		)
		piece(
			m,
			"CrossVertical",
			Vector3.new(0.34, 1.1, 0.06),
			CFrame.new(0, 0, 0.99),
			Color3.fromRGB(255, 239, 135)
		)
	elseif skin == "Vampire" then
		for _, x in { -0.36, 0.36 } do
			local tooth = Instance.new("WedgePart")
			tooth.Name = "Fang"
			tooth.Size = Vector3.new(0.18, 0.67, 0.28)
			tooth.CFrame = CFrame.new(x, -1.08, 0.60) * CFrame.Angles(0, math.pi / 2, math.pi)
			tooth.Anchored = true
			tooth.CanCollide = false
			tooth.Color = Color3.fromRGB(255, 255, 235)
			tooth.Parent = m
		end
	elseif skin == "Acid" then
		local patches = {
			Vector3.new(-0.12, 0.40, 0.36),
			Vector3.new(-0.56, -0.06, 0.20),
			Vector3.new(-0.18, -0.50, 0.10),
			Vector3.new(-0.18, -0.70, 0.07),
			Vector3.new(0.02, -0.23, 0.09),
			Vector3.new(0.41, 0.72, 0.13),
			Vector3.new(0.66, -0.30, 0.20),
		}
		for _, patch in patches do
			local z = math.sqrt(1 - patch.X * patch.X - patch.Y * patch.Y)
			local n = Vector3.new(patch.X, patch.Y, z)
			local s = patch.Z
			local p = piece(
				m,
				"AcidPatch",
				Vector3.new(s * 2, s * 2, 0.035),
				CFrame.lookAt(n * 1.006, n * 2),
				Color3.fromRGB(65, 150, 6),
				true
			)
			p.Reflectance = 0
		end
	elseif skin == "Cell" then
		body.Transparency = 0.36
		local core = piece(
			m,
			"LivingCore",
			Vector3.new(1.5, 1.5, 1.5),
			CFrame.identity,
			Color3.fromRGB(165, 255, 119),
			true
		)
		core.Material = Enum.Material.Neon
		for i = 1, 5 do
			local a = i * 1.26
			piece(
				m,
				"CellNucleus",
				Vector3.new(0.47, 0.47, 0.47),
				CFrame.new(math.cos(a) * 0.36, math.sin(a) * 0.36, 0.48),
				Color3.fromRGB(215, 255, 155),
				true
			)
		end
		local shell = piece(
			m,
			"Membrane",
			Vector3.new(2.1, 2.1, 2.1),
			CFrame.identity,
			Color3.fromRGB(183, 255, 163),
			true
		)
		shell.Transparency = 0.72
	elseif skin == "Axe" then
		for i = 1, 96 do
			local a = i * math.pi / 48
			local cf = CFrame.new(0, math.sin(a), math.cos(a)) * CFrame.Angles(-a, 0, 0)
			local outer =
				piece(m, "HotSeam", Vector3.new(0.22, 0.075, 0.035), cf, Color3.fromRGB(255, 92, 20))
			outer.Material = Enum.Material.Neon
			local core =
				piece(m, "SeamCore", Vector3.new(0.09, 0.075, 0.045), cf, Color3.fromRGB(255, 186, 54))
			core.Material = Enum.Material.Neon
		end
		local weapon = Instance.new("Model")
		weapon.Name = "Weapon"
		piece(
			weapon,
			"Handle",
			Vector3.new(0.12, 2.9, 0.13),
			CFrame.new(0, 0.95, 0.15),
			Color3.fromRGB(99, 54, 28)
		)
		piece(
			weapon,
			"Socket",
			Vector3.new(0.27, 0.32, 0.23),
			CFrame.new(0, 2.05, 0.15),
			Color3.fromRGB(91, 117, 139)
		)
		for i = 0, 6 do
			local a = math.rad(-65 + i * 19)
			piece(
				weapon,
				"Blade",
				Vector3.new(0.38, 0.40, 0.13),
				CFrame.new(0.22 + math.cos(a) * 0.36, 2.05 + math.sin(a) * 0.38, 0.15)
					* CFrame.Angles(0, 0, a),
				Color3.fromRGB(182, 218, 242)
			)
		end
		weapon.Parent = m
		weapon.WorldPivot = CFrame.identity
	end
	m.Parent = parent
	m.WorldPivot = CFrame.identity
	return m
end
function Art.viewport(parent: Instance, name: string, skin: string): (ViewportFrame, Model)
	local v = Instance.new("ViewportFrame")
	v.Name = name
	v.BackgroundTransparency = 1
	v.Ambient = Color3.fromRGB(78, 91, 113)
	v.LightColor = Color3.fromRGB(255, 255, 255)
	v.LightDirection = Vector3.new(-1, -1, -2)
	local world = Instance.new("WorldModel")
	world.Parent = v
	local model = Art.build(world, skin)
	local c = Instance.new("Camera")
	c.FieldOfView = 30
	c.CFrame = CFrame.new(0, 0, 5.6)
	c.Parent = v
	v.CurrentCamera = c
	v.Parent = parent
	return v, model
end
return table.freeze(Art)
