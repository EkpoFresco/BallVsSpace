--!strict
local Players = game:GetService("Players")
local Hud = {}
local background = Color3.fromRGB(9, 16, 32)
local ink = Color3.fromRGB(235, 244, 252)
local cyan = Color3.fromRGB(75, 220, 234)
local coral = Color3.fromRGB(255, 139, 122)
function Hud.label(
	parent: Instance,
	name: string,
	text: string,
	size: UDim2,
	position: UDim2,
	fontSize: number
): TextLabel
	local l = Instance.new("TextLabel")
	l.Name = name
	l.Size = size
	l.Position = position
	l.Text = text
	l.TextSize = fontSize
	l.TextColor3 = ink
	l.Font = Enum.Font.GothamBold
	l.TextStrokeTransparency = 0.1
	l.TextStrokeColor3 = Color3.fromRGB(3, 6, 12)
	l.BackgroundTransparency = 1
	l.TextWrapped = true
	l.Parent = parent
	return l
end
function Hud.button(parent: Instance, name: string, text: string, size: UDim2, position: UDim2): TextButton
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = text
	b.Size = size
	b.Position = position
	b.BackgroundColor3 = Color3.fromRGB(94, 88, 153)
	b.TextColor3 = ink
	b.Font = Enum.Font.GothamBlack
	b.TextStrokeTransparency = 0
	b.TextSize = 16
	b.TextWrapped = true
	b.BorderSizePixel = 0
	b.AutoButtonColor = true
	b.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 2)
	corner.Parent = b
	local border = Instance.new("UIStroke")
	border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	border.Color = Color3.fromRGB(8, 10, 20)
	border.Thickness = 2
	border.Parent = b
	return b
end
function Hud.panel(parent: Instance, name: string, height: number, position: UDim2, anchor: Vector2): Frame
	local p = Instance.new("Frame")
	p.Name = name
	p.Size = UDim2.new(1, -24, 0, height)
	p.Position = position
	p.AnchorPoint = anchor
	p.BackgroundColor3 = background
	p.BackgroundTransparency = 0.08
	p.BorderSizePixel = 0
	p.Parent = parent
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 2)
	c.Parent = p
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(720, 1000)
	constraint.Parent = p
	return p
end
local function preview(parent: Instance, color: Color3, avatar: boolean): ViewportFrame
	local v = Instance.new("ViewportFrame")
	v.Name = if avatar then "PlayerFigure" else "KitPreview"
	v.BackgroundTransparency = 1
	v.Ambient = Color3.fromRGB(170, 185, 215)
	v.LightColor = Color3.new(1, 1, 1)
	v.LightDirection = Vector3.new(-1, -1, -1)
	v.Parent = parent
	local camera = Instance.new("Camera")
	camera.FieldOfView = 35
	camera.CFrame = CFrame.lookAt(Vector3.new(0, 1.3, if avatar then 12 else 7), Vector3.new(0, 0.7, 0))
	camera.Parent = v
	v.CurrentCamera = camera
	local function piece(name: string, size: Vector3, at: Vector3, tint: Color3, sphere: boolean)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Position = at
		p.Color = tint
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored = true
		if sphere then
			p.Shape = Enum.PartType.Ball
		end
		p.Parent = v
	end
	if avatar then
		piece("Head", Vector3.new(1.35, 1.35, 1.35), Vector3.new(0, 2.5, 0), color, true)
		piece("Visor", Vector3.new(1.12, 0.35, 0.2), Vector3.new(0, 2.55, 0.62), background, false)
		piece("Torso", Vector3.new(2, 2, 0.9), Vector3.new(0, 0.8, 0), Color3.fromRGB(28, 44, 73), false)
		piece("Badge", Vector3.new(1, 0.45, 0.1), Vector3.new(0, 1.2, 0.5), color, false)
		for _, x in { -1.45, 1.45 } do
			piece("Arm", Vector3.new(0.75, 2, 0.8), Vector3.new(x, 0.8, 0), color, false)
		end
		for _, x in { -0.55, 0.55 } do
			piece(
				"Leg",
				Vector3.new(0.9, 1.8, 0.9),
				Vector3.new(x, -1.15, 0),
				Color3.fromRGB(20, 30, 50),
				false
			)
		end
	else
		piece("Body", Vector3.new(2.4, 2.4, 2.4), Vector3.new(0, 0.7, 0), color, true)
		piece("Accent", Vector3.new(0.35, 2.1, 0.25), Vector3.new(0, 0.7, 1.13), ink, false)
	end
	return v
end
function Hud.new()
	local gui = Instance.new("ScreenGui")
	gui.Name = "BallVsSpace"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	local top = Hud.panel(gui, "Score", 100, UDim2.new(0.5, 0, 0, 8), Vector2.new(0.5, 0))
	local phase = Hud.label(top, "Phase", "BALL VS SPACE", UDim2.new(1, 0, 0, 24), UDim2.fromOffset(0, 6), 18)
	phase.Font = Enum.Font.GothamBold
	local scoreA =
		Hud.label(top, "ScoreA", "◇  0.0%", UDim2.new(0.34, 0, 0, 30), UDim2.fromOffset(8, 28), 20)
	scoreA.TextColor3 = cyan
	local scoreB =
		Hud.label(top, "ScoreB", "0.0%  ○", UDim2.new(0.34, 0, 0, 30), UDim2.new(0.66, -8, 0, 28), 20)
	scoreB.TextColor3 = coral
	local timer = Hud.label(
		top,
		"Clock",
		"PICK · AIM · TAKE SPACE",
		UDim2.new(0.32, 0, 0, 32),
		UDim2.new(0.34, 0, 0, 28),
		16
	)
	local bar = Instance.new("Frame")
	bar.Name = "Area"
	bar.BackgroundColor3 = Color3.fromRGB(65, 76, 90)
	bar.BorderSizePixel = 0
	bar.Size = UDim2.new(1, -32, 0, 8)
	bar.Position = UDim2.fromOffset(16, 64)
	bar.Parent = top
	local barA = Instance.new("Frame")
	barA.Name = "A"
	barA.BorderSizePixel = 0
	barA.BackgroundColor3 = cyan
	barA.Size = UDim2.fromScale(0, 1)
	barA.Parent = bar
	local barB = Instance.new("Frame")
	barB.Name = "B"
	barB.BorderSizePixel = 0
	barB.BackgroundColor3 = coral
	barB.AnchorPoint = Vector2.new(1, 0)
	barB.Position = UDim2.fromScale(1, 0)
	barB.Size = UDim2.fromScale(0, 1)
	barB.Parent = bar
	local points = Hud.label(
		top,
		"Points",
		"Most space at the buzzer wins",
		UDim2.new(1, 0, 0, 22),
		UDim2.fromOffset(0, 74),
		14
	)
	local footer = Hud.panel(gui, "Controls", 180, UDim2.new(0.5, 0, 1, -12), Vector2.new(0.5, 1))
	local hint = Hud.label(
		footer,
		"Hint",
		"Pick your ball. Aim your opening.",
		UDim2.new(1, -16, 0, 46),
		UDim2.fromOffset(8, 4),
		16
	)
	local left = Hud.button(footer, "Left", "PLAY 1V1", UDim2.new(0.5, -12, 0, 64), UDim2.fromOffset(8, 54))
	local right =
		Hud.button(footer, "Right", "PRACTICE", UDim2.new(0.5, -12, 0, 64), UDim2.new(0.5, 4, 0, 54))
	local primary =
		Hud.button(footer, "Primary", "LOCK CHOICE", UDim2.new(1, -16, 0, 48), UDim2.fromOffset(8, 126))
	primary.BackgroundColor3 = Color3.fromRGB(47, 103, 115)
	local status = Hud.label(
		gui,
		"Status",
		"M1 prototype · session only",
		UDim2.new(1, -24, 0, 28),
		UDim2.fromOffset(12, 110),
		14
	)
	local help = Hud.label(
		gui,
		"Help",
		"Keep covering to strengthen.\nEnemy coverage steals.",
		UDim2.new(1, -24, 0, 44),
		UDim2.new(0, 12, 1, -240),
		16
	)
	local icons = {}
	for i, button in { left, right } do
		local icon = preview(button, if i == 1 then cyan else coral, false)
		icon.AnchorPoint = Vector2.new(0.5, 0)
		icon.Position = UDim2.fromScale(0.5, 0.03)
		icon.Size = UDim2.fromScale(0.85, 0.64)
		icons[i] = icon
	end
	local sideFrames = {}
	local sideLabels = {}
	for i = 1, 2 do
		local frame = Instance.new("Frame")
		frame.Name = "PlayerSide" .. i
		frame.Size = UDim2.fromOffset(112, 260)
		frame.BackgroundTransparency = 1
		frame.Parent = gui
		local label = Hud.label(frame, "PlayerName", "", UDim2.new(1, 0, 0, 52), UDim2.fromOffset(0, 0), 16)
		label.TextColor3 = if i == 1 then cyan else coral
		local figure = preview(frame, if i == 1 then cyan else coral, true)
		figure.Position = UDim2.fromOffset(0, 52)
		figure.Size = UDim2.new(1, 0, 0, 208)
		sideFrames[i] = frame
		sideLabels[i] = label
	end
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
	return {
		top = top,
		footer = footer,
		icons = icons,
		sideFrames = sideFrames,
		sideLabels = sideLabels,
		gui = gui,
		phase = phase,
		scoreA = scoreA,
		scoreB = scoreB,
		timer = timer,
		points = points,
		barA = barA,
		barB = barB,
		hint = hint,
		left = left,
		right = right,
		primary = primary,
		status = status,
		help = help,
	}
end
export type State = typeof(Hud.new())
function Hud.layout(h: State, phase: string)
	local camera = workspace.CurrentCamera
	if not camera then
		return
	end
	local size = camera.ViewportSize
	local court =
		math.min(math.max(180, size.Y - 92), math.max(180, size.X - (if size.X >= 700 then 260 else 28)))
	h.top.BackgroundTransparency = 1
	h.top.Size = UDim2.fromOffset(math.min(court, 720), 92)
	h.help.Visible = false
	h.status.Position = UDim2.new(0, 12, 1, -25)
	h.status.TextSize = 12
	h.footer.BackgroundTransparency = 0.08
	h.footer.Size = UDim2.fromOffset(math.min(500, size.X - 28), 180)
	h.footer.Position = UDim2.new(0.5, 0, 1, -34)
	h.footer.AnchorPoint = Vector2.new(0.5, 1)
	h.hint.Visible = true
	h.hint.Position = UDim2.fromOffset(8, 4)
	h.hint.Size = UDim2.new(1, -16, 0, 46)
	h.left.Position = UDim2.fromOffset(8, 54)
	h.right.Position = UDim2.new(0.5, 4, 0, 54)
	h.left.Size = UDim2.new(0.5, -12, 0, 64)
	h.right.Size = h.left.Size
	h.left.TextYAlignment = Enum.TextYAlignment.Center
	h.right.TextYAlignment = Enum.TextYAlignment.Center
	h.primary.Position = UDim2.fromOffset(8, 126)
	h.primary.Size = UDim2.new(1, -16, 0, 48)
	h.primary.BackgroundColor3 = Color3.fromRGB(216, 153, 0)
	for i, frame in h.sideFrames do
		frame.Visible = size.X >= 700 and phase ~= "Lobby" and phase ~= "Queued"
		frame.AnchorPoint = Vector2.new(if i == 1 then 1 else 0, 0.5)
		frame.Position = UDim2.new(0.5, (if i == 1 then -1 else 1) * (court / 2 + 8), 0.5, 0)
	end
	for _, icon in h.icons do
		icon.Visible = phase == "Draft"
	end
	if phase == "Draft" then
		local height = math.min(320, size.Y - 140)
		h.footer.Size = UDim2.fromOffset(math.min(500, court - 16), height)
		h.footer.AnchorPoint = Vector2.new(0.5, 0.5)
		h.footer.Position = UDim2.new(0.5, 0, 0.5, -8)
		h.left.Size = UDim2.new(0.5, -12, 0, height - 126)
		h.right.Size = h.left.Size
		h.left.TextYAlignment = Enum.TextYAlignment.Bottom
		h.right.TextYAlignment = Enum.TextYAlignment.Bottom
		h.primary.Position = UDim2.new(0, 8, 1, -52)
		h.primary.Size = UDim2.new(1, -16, 0, 44)
	elseif phase == "Aim" then
		h.footer.Size = UDim2.fromOffset(math.min(310, size.X - 28), 110)
		h.footer.BackgroundTransparency = 1
		h.left.Size = UDim2.fromOffset(48, 48)
		h.right.Size = h.left.Size
		h.left.Position = UDim2.fromOffset(0, 56)
		h.right.Position = UDim2.new(1, -48, 0, 56)
		h.left.Text = "−15°"
		h.right.Text = "+15°"
		h.primary.Position = UDim2.fromOffset(56, 56)
		h.primary.Size = UDim2.new(1, -112, 0, 48)
	elseif phase == "Battle" or phase == "Overtime" or phase == "Countdown" then
		h.footer.Size = UDim2.fromOffset(math.min(500, court - 16), 56)
		h.footer.BackgroundTransparency = 1
		h.primary.Visible = false
	elseif phase == "RoundResult" or phase == "MatchResult" then
		h.footer.AnchorPoint = Vector2.new(0.5, 0.5)
		h.footer.Position = UDim2.new(0.5, 0, 0.5, -8)
	else
		h.left.BackgroundColor3 = Color3.fromRGB(91, 181, 0)
		h.right.BackgroundColor3 = Color3.fromRGB(94, 88, 153)
	end
end
return table.freeze(Hud)
