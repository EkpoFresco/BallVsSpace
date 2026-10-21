--!strict
-- Original flat sprites shared by portraits and combat. Shared swept capsules
-- remain the contact approximation; decorative grips and chains are inert.
local Weapon = require(game:GetService("ReplicatedStorage").Shared.WeaponGeometry)
local Heroes = require(game:GetService("ReplicatedStorage").Shared.HeroDefinitions)
local Art = {}
Art.asset = "rbxassetid://77146942181804"
local index: { [string]: number } = {}
for i, id in Heroes.ids do
	index[id] = i - 1
end
for i, id in { "Guard", "Seed", "Wood", "Metal", "Chain", "Collar", "Body", "Glint" } do
	index[id] = 29 + i
end
export type Stroke = { edge: ImageLabel, handle: ImageLabel }
export type Assembly = { edges: { Stroke }, tail: ImageLabel, guard: ImageLabel }
function Art.set(image: ImageLabel, id: string)
	if image:GetAttribute("Sprite") == id then
		return
	end
	local n = index[id]
	assert(n, "Missing original weapon sprite: " .. id)
	image.Image = Art.asset
	image.ImageRectOffset = Vector2.new(n % 8 * 128, math.floor(n / 8) * 128)
	image.ImageRectSize = Vector2.new(128, if id == "Body" or id == "Glint" then 128 else 64)
	image:SetAttribute("Sprite", id)
end
function Art.image(parent: Instance, name: string, id: string): ImageLabel
	local image = Instance.new("ImageLabel")
	image.Name = name
	image.BackgroundTransparency = 1
	image.AnchorPoint = Vector2.new(0.5, 0.5)
	image.ScaleType = Enum.ScaleType.Stretch
	Art.set(image, id)
	image.Parent = parent
	return image
end
function Art.new(parent: Instance, prefix: string): Assembly
	local tail = Art.image(parent, prefix .. "Grip", "Wood")
	tail.ZIndex = 1
	tail.Visible = false
	local guard = Art.image(parent, prefix .. "Shield", "Guard")
	guard.ZIndex = 2
	guard.Visible = false
	local edges: { Stroke } = {}
	for n = 1, 5 do
		local handle = Art.image(parent, prefix .. "Handle" .. n, "Wood")
		handle.ZIndex = 1
		handle.Visible = false
		local edge = Art.image(parent, prefix .. "WeaponEdge" .. n, "Astra")
		edge.ZIndex = 2
		edge.Visible = false
		table.insert(edges, { handle = handle, edge = edge })
	end
	return { edges = edges, tail = tail, guard = guard }
end
local function segment(
	image: ImageLabel,
	ax: number,
	az: number,
	bx: number,
	bz: number,
	width: number,
	cap: number,
	scale: number,
	ox: number,
	oz: number
)
	local dx, dz = bx - ax, bz - az
	image.Position = UDim2.fromScale(ox + (ax + bx) / 2 * scale, oz + (az + bz) / 2 * scale)
	image.Size = UDim2.fromScale((math.sqrt(dx * dx + dz * dz) + cap) * scale, width * scale)
	image.Rotation = math.deg(math.atan2(dz, dx))
	image.Visible = true
end
function Art.draw(
	assembly: Assembly,
	id: string,
	x: number,
	z: number,
	angle: number,
	edges: { Weapon.Edge },
	scale: number,
	ox: number,
	oz: number,
	guardSpent: boolean
)
	for _, item in assembly.edges do
		item.edge.Visible = false
		item.handle.Visible = false
	end
	assembly.tail.Visible = false
	assembly.guard.Visible = false
	if #edges == 0 then
		return
	end
	local hero = Heroes.heroes[id]
	local dx, dz = math.cos(angle), math.sin(angle)
	local curved = id == "Veyra" or id == "Toren" or id == "Runa"
	local chained = hero.family == "Chains" and id ~= "Mira"
	if not Weapon.isProjectile(id) then
		local back = if hero.family == "Polearms" or hero.family == "Heavy" then -4.4 else -2.8
		Art.set(assembly.tail, if id == "Pax" or id == "Cira" then "Metal" else "Wood")
		segment(
			assembly.tail,
			x + dx * back,
			z + dz * back,
			x + dx * 3.8,
			z + dz * 3.8,
			1.1,
			0,
			scale,
			ox,
			oz
		)
	end
	for n, edge in edges do
		local item = assembly.edges[n]
		if not item then
			break
		end
		if edge.kind == "guard" then
			local shield = assembly.guard
			shield.Position = UDim2.fromScale(ox + (x - dx * 2.8) * scale, oz + (z - dz * 2.8) * scale)
			shield.Size = UDim2.fromScale(2.7 * scale, 7.2 * scale)
			shield.Rotation = math.deg(angle)
			shield.ImageTransparency = if guardSpent then 0.65 else 0
			shield.Visible = true
			continue
		end
		Art.set(
			item.edge,
			if edge.kind == "guard" then "Guard" elseif edge.kind == "seed" then "Seed" else id
		)
		segment(
			item.edge,
			edge.ax,
			edge.az,
			edge.bx,
			edge.bz,
			edge.radius * 2,
			edge.radius * 2,
			scale,
			ox,
			oz
		)
		if Vector2.new(edge.bx - edge.ax, edge.bz - edge.az).Magnitude < 0.01 then
			item.edge.Rotation = math.deg(angle)
		end
		item.edge.ImageColor3 = if edge.strength == 2
			then Color3.fromRGB(255, 219, 135)
			else Color3.new(1, 1, 1)
		item.edge.ImageTransparency = if edge.kind == "guard" and guardSpent then 0.65 else 0
		if edge.kind == "guard" or edge.kind == "seed" or edge.projectile or Weapon.isProjectile(id) then
			continue
		end
		if (curved or id == "Mira") and n > 1 then
			continue
		end
		local ax, az, bx, bz = x, z, edge.ax, edge.az
		if hero.family == "Heavy" or chained then
			bx, bz = (edge.ax + edge.bx) / 2, (edge.az + edge.bz) / 2
		elseif curved then
			bx, bz = edge.bx, edge.bz
		end
		if id == "Nerio" and n ~= 2 then
			ax, az = x + dx * 5.5, z + dz * 5.5
		end
		if chained then
			local distance = math.max(0.01, Vector2.new(bx - x, bz - z).Magnitude)
			ax, az = x + (bx - x) / distance * 3.3, z + (bz - z) / distance * 3.3
		end
		Art.set(
			item.handle,
			if chained
				then "Chain"
				elseif id == "Cira" or id == "Pax" or (id == "Nerio" and n ~= 2) then "Metal"
				else "Wood"
		)
		segment(item.handle, ax, az, bx, bz, if chained then 1.6 else 1.05, 0, scale, ox, oz)
	end
end
return table.freeze(Art)
