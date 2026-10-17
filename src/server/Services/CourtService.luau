--!strict
local Lighting = game:GetService("Lighting")
local PhysicsService = game:GetService("PhysicsService")
local Workspace = game:GetService("Workspace")
local Court = {}
function Court.build()
	local existing = Workspace:FindFirstChild("BVSCourt")
	if existing then
		existing:Destroy()
	end
	local root = Instance.new("Folder")
	root.Name = "BVSCourt"
	local function part(
		name: string,
		size: Vector3,
		position: Vector3,
		color: Color3,
		material: Enum.Material
	): Part
		local p = Instance.new("Part")
		p.Name = name
		p.Anchored = true
		p.Size = size
		p.Position = position
		p.Color = color
		p.Material = material
		p.CastShadow = false
		p.CanTouch = false
		p.CanQuery = false
		p.CanCollide = false
		p.Parent = root
		return p
	end
	part(
		"Floor",
		Vector3.new(64, 1, 64),
		Vector3.new(0, -0.6, 0),
		Color3.fromRGB(22, 28, 40),
		Enum.Material.SmoothPlastic
	)
	for _, x in { -33, 33 } do
		part(
			"Rim",
			Vector3.new(1, 0.6, 67),
			Vector3.new(x, 0, 0),
			Color3.fromRGB(60, 78, 96),
			Enum.Material.Metal
		)
	end
	for _, z in { -33, 33 } do
		part(
			"Rim",
			Vector3.new(67, 0.6, 1),
			Vector3.new(0, 0, z),
			Color3.fromRGB(60, 78, 96),
			Enum.Material.Metal
		)
	end
	part(
		"TeamA",
		Vector3.new(0.3, 0.2, 20),
		Vector3.new(-33, 0.5, 0),
		Color3.fromRGB(65, 220, 235),
		Enum.Material.Neon
	)
	part(
		"TeamB",
		Vector3.new(0.3, 0.2, 20),
		Vector3.new(33, 0.5, 0),
		Color3.fromRGB(255, 125, 110),
		Enum.Material.Neon
	)
	root.Parent = Workspace
	for _, name in { "LobbyCharacters", "LobbyWorld", "ArenaVisual", "Effects" } do
		pcall(function()
			PhysicsService:RegisterCollisionGroup(name)
		end)
	end
	for _, name in { "LobbyCharacters", "LobbyWorld", "ArenaVisual", "Effects" } do
		PhysicsService:CollisionGroupSetCollidable("ArenaVisual", name, false)
		PhysicsService:CollisionGroupSetCollidable("Effects", name, false)
	end
	PhysicsService:CollisionGroupSetCollidable("LobbyCharacters", "LobbyCharacters", false)
	Lighting.ClockTime = 0
	Lighting.Brightness = 2
	Lighting.Ambient = Color3.fromRGB(130, 145, 165)
	Lighting.OutdoorAmbient = Color3.fromRGB(130, 145, 165)
	local base = Workspace:FindFirstChild("Baseplate")
	if base and base:IsA("BasePart") then
		base:Destroy()
	end
	local spawn = Workspace:FindFirstChild("SpawnLocation")
	if spawn and spawn:IsA("BasePart") then
		spawn:Destroy()
	end
end
return table.freeze(Court)
