--!strict
local Players = game:GetService("Players")
local Hud = {}
local background = Color3.fromRGB(17, 24, 36)
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
	l.Font = Enum.Font.Gotham
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
	b.BackgroundColor3 = Color3.fromRGB(40, 56, 74)
	b.TextColor3 = ink
	b.Font = Enum.Font.GothamBold
	b.TextSize = 16
	b.TextWrapped = true
	b.BorderSizePixel = 0
	b.AutoButtonColor = true
	b.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = b
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
	c.CornerRadius = UDim.new(0, 12)
	c.Parent = p
	local constraint = Instance.new("UISizeConstraint")
	constraint.MaxSize = Vector2.new(720, 1000)
	constraint.Parent = p
	return p
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
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
	return {
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
return table.freeze(Hud)
