--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Shared = game:GetService("ReplicatedStorage").Shared
local Protocol = require(Shared.Protocol)
local ViewTypes = require(Shared.ViewTypes)
local Renderer = {}
local colors = { Color3.fromRGB(84, 234, 247), Color3.fromRGB(255, 143, 129) }
export type Visual =
	{ body: Part, label: TextLabel, ring: { Part }, accent: Part, aim: { Part }, team: number }
export type State = { folder: Folder, balls: { Visual } }
local function part(root: Instance, name: string): Part
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Material = Enum.Material.SmoothPlastic
	p.Parent = root
	return p
end
function Renderer.new(): State
	local folder = Instance.new("Folder")
	folder.Name = "BVSBalls"
	folder.Parent = Workspace
	local gui = Instance.new("ScreenGui")
	gui.Name = "BVSBallLabels"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
	local visuals = {}
	for i = 1, 2 do
		local body = part(folder, "Ball" .. i)
		body.Shape = Enum.PartType.Ball
		body.Size = Vector3.new(3, 3, 3)
		body.Color = colors[i]
		local accent = part(folder, "KitAccent" .. i)
		accent.Size = Vector3.new(2.2, 0.25, 2.2)
		accent.Color = Color3.fromRGB(239, 247, 255)
		local label = Instance.new("TextLabel")
		label.Name = "Ball" .. i
		label.Size = UDim2.fromOffset(150, 44)
		label.AnchorPoint = Vector2.new(0.5, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextSize = 14
		label.TextStrokeTransparency = 0.3
		label.Parent = gui
		local ring = {}
		for j = 1, 32 do
			local p = part(folder, "Brush")
			p.Color = colors[i]
			p.Transparency = 0.45
			ring[j] = p
		end
		local aim = {}
		for j = 1, 2 do
			local p = part(folder, "Aim")
			p.Color = colors[i]
			p.Material = Enum.Material.Neon
			aim[j] = p
		end
		table.insert(
			visuals,
			{ body = body, label = label, ring = ring, accent = accent, aim = aim, team = i }
		)
	end
	return { folder = folder, balls = visuals }
end
function Renderer.line(p: Part, a: Vector3, b: Vector3, width: number)
	local length = (b - a).Magnitude
	p.Size = Vector3.new(width, 0.09, math.max(0.01, length))
	p.CFrame = CFrame.lookAt((a + b) / 2, b)
end
function Renderer.render(
	state: State,
	positions: { Protocol.Motion },
	view: ViewTypes.State?,
	reduced: boolean
)
	for i, v in state.balls do
		local b = positions[i]
		local seat = if view then view.seats[i] else nil
		local visible = b ~= nil and view ~= nil and view.phase ~= "ReadyCheck" and view.phase ~= "Draft"
		v.body.Transparency = if visible then 0 else 1
		v.accent.Transparency = if visible then 0 else 1
		v.label.Visible = visible
		for _, p in v.ring do
			p.Transparency = if visible then 0.5 else 1
		end
		for _, p in v.aim do
			p.Transparency = 1
		end
		if not visible or not b or not view or not seat then
			continue
		end
		v.body.Position = Vector3.new(b.x, 1.65, b.z)
		local camera = Workspace.CurrentCamera
		if camera then
			local screen, onScreen = camera:WorldToViewportPoint(Vector3.new(b.x, 4.5, b.z))
			v.label.Position = UDim2.fromOffset(screen.X, screen.Y)
			v.label.Visible = onScreen
		end
		local anchor = seat.kitId == "Anchor"
		v.accent.Size = if anchor then Vector3.new(2.4, 0.25, 2.4) else Vector3.new(0.4, 0.25, 2.6)
		v.accent.CFrame = CFrame.new(b.x, 3.2, b.z)
			* CFrame.Angles(0, if anchor then math.pi / 4 else math.atan2(b.vx, b.vz), 0)
		local remaining = math.max(0, (b.nextAbilityTick - view.tick) / 60)
		local symbol = if seat.team == 1 then "◇" else "○"
		v.label.Text = symbol
			.. " "
			.. (seat.kitId or "Hidden")
			.. "\n"
			.. (
				if view.phase == "Battle" or view.phase == "Overtime"
					then string.format("%.1fs", remaining)
					else seat.name
			)
		local radius = b.brush
		local preview = remaining > 0
			and remaining <= (if anchor then 0.5 else 0.4)
			and (view.phase == "Battle" or view.phase == "Overtime")
		if preview and not reduced then
			radius = if anchor then 4.5 + (0.5 - remaining) * 5 else 6 + remaining * 3
		end
		for j, p in v.ring do
			local angle = (j - 1) * math.pi / 16
			local nextAngle = j * math.pi / 16
			Renderer.line(
				p,
				Vector3.new(b.x + math.cos(angle) * radius, 0.25, b.z + math.sin(angle) * radius),
				Vector3.new(b.x + math.cos(nextAngle) * radius, 0.25, b.z + math.sin(nextAngle) * radius),
				if preview then 0.16 else 0.09
			)
		end
	end
end
return table.freeze(Renderer)
