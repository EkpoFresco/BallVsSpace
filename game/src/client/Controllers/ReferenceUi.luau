--!strict
local Ui = {}
function Ui.polygon(parent: Instance, name: string, points: { Vector2 }, color: Color3): Frame
	local container = Instance.new("Frame")
	container.Name = name
	container.Size = UDim2.fromScale(1, 1)
	container.BackgroundTransparency = 1
	container.Parent = parent
	local low, high = math.huge, -math.huge
	for _, p in points do
		low = math.min(low, p.Y)
		high = math.max(high, p.Y)
	end
	for y = math.floor(low), math.ceil(high) - 1 do
		local intersections = {}
		for i, a in points do
			local b = points[i % #points + 1]
			if (a.Y <= y + 0.5 and b.Y > y + 0.5) or (b.Y <= y + 0.5 and a.Y > y + 0.5) then
				table.insert(intersections, a.X + (y + 0.5 - a.Y) * (b.X - a.X) / (b.Y - a.Y))
			end
		end
		table.sort(intersections)
		for i = 1, #intersections - 1, 2 do
			local row = Instance.new("Frame")
			row.BorderSizePixel = 0
			row.BackgroundColor3 = color
			row.Position = UDim2.fromOffset(intersections[i], y)
			row.Size = UDim2.fromOffset(intersections[i + 1] - intersections[i], 1.1)
			row.Parent = container
		end
	end
	return container
end
Ui.displayFont = Font.new("rbxasset://fonts/families/Michroma.json")
Ui.cardFont = Font.new("rbxasset://fonts/families/FredokaOne.json")
function Ui.frame(
	parent: Instance,
	name: string,
	x: number,
	y: number,
	w: number,
	h: number,
	color: Color3
): Frame
	local f = Instance.new("Frame")
	f.Name = name
	f.Position = UDim2.fromOffset(x, y)
	f.Size = UDim2.fromOffset(w, h)
	f.BackgroundColor3 = color
	f.BorderSizePixel = 0
	f.Parent = parent
	return f
end
function Ui.text(
	parent: Instance,
	name: string,
	value: string,
	x: number,
	y: number,
	w: number,
	h: number,
	size: number,
	display: boolean?
): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = name
	t.Position = UDim2.fromOffset(x, y)
	t.Size = UDim2.fromOffset(w, h)
	t.BackgroundTransparency = 1
	t.FontFace = if display then Ui.displayFont else Ui.cardFont
	t.TextSize = size
	t.Text = value
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextWrapped = true
	t.Parent = parent
	local stroke = Instance.new("UIStroke")
	stroke.Name = "TextOutline"
	stroke.Color = Color3.fromRGB(5, 8, 13)
	stroke.Thickness = if display then 1.5 else 1.2
	stroke.Parent = t
	return t
end
function Ui.gradient(parent: Instance, top: Color3, bottom: Color3, rotation: number?): UIGradient
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new(top, bottom)
	g.Rotation = rotation or 90
	g.Parent = parent
	return g
end
function Ui.button(
	parent: Instance,
	name: string,
	value: string,
	x: number,
	y: number,
	w: number,
	h: number,
	color: Color3
): TextButton
	local b = Instance.new("TextButton")
	b.Name = name
	b.Position = UDim2.fromOffset(x, y)
	b.Size = UDim2.fromOffset(w, h)
	b.Text = value
	b.FontFace = Ui.displayFont
	b.TextSize = 20
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextStrokeTransparency = 0
	b.BackgroundColor3 = Color3.new(1, 1, 1)
	b.BorderSizePixel = 0
	b.AutoButtonColor = true
	b.Parent = parent
	b.BackgroundColor3 = color
	local background = Ui.frame(b, "ButtonFill", 0, 0, w, h, Color3.new(1, 1, 1))
	background.Size = UDim2.fromScale(1, 1)
	background.ZIndex = 0
	Ui.gradient(background, color, color:Lerp(Color3.new(0, 0, 0), 0.28))
	b.TextTransparency = 1
	b.TextStrokeTransparency = 1
	local caption = Ui.text(b, "ButtonText", value, 0, 0, w, h, 20, true)
	caption.Size = UDim2.fromScale(1, 1)
	caption.ZIndex = 2
	b:GetPropertyChangedSignal("Text"):Connect(function()
		caption.Text = b.Text
	end)
	b:GetPropertyChangedSignal("TextSize"):Connect(function()
		caption.TextSize = b.TextSize
	end)
	b:GetPropertyChangedSignal("TextYAlignment"):Connect(function()
		caption.TextYAlignment = b.TextYAlignment
	end)
	local edge = Instance.new("UIStroke")
	edge.Name = "Edge"
	edge.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	edge.Color = color:Lerp(Color3.new(0, 0, 0), 0.6)
	edge.Thickness = 2
	edge.Parent = b
	return b
end
function Ui.heart(parent: Instance, x: number, y: number, size: number): Frame
	local f = Ui.frame(parent, "Heart", x, y, size, size, Color3.new())
	f.BackgroundTransparency = 1
	-- One continuous silhouette avoids the square shoulder of overlapping circles.
	local points = {}
	for i = 0, 63 do
		local t = i * math.pi * 2 / 64
		local px = 16 * math.sin(t) ^ 3
		local py = 13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t)
		table.insert(points, Vector2.new((px + 16) / 32 * size, (12 - py) / 29 * size * 0.92))
	end
	Ui.polygon(f, "Silhouette", points, Color3.fromRGB(230, 39, 66))
	return f
end
function Ui.gear(parent: Instance, x: number, y: number, size: number, background: Color3): Frame
	local f = Ui.frame(parent, "GearIcon", x, y, size, size, Color3.new())
	f.BackgroundTransparency = 1
	f.ZIndex = 3
	local points = {}
	for tooth = 0, 7 do
		for _, corner in
			{
				Vector2.new(-0.5, 0.36),
				Vector2.new(-0.27, 0.5),
				Vector2.new(0.27, 0.5),
				Vector2.new(0.5, 0.36),
			}
		do
			local angle = (tooth + corner.X) * math.pi / 4
			table.insert(
				points,
				Vector2.new(0.5 + math.cos(angle) * corner.Y, 0.5 + math.sin(angle) * corner.Y) * size
			)
		end
	end
	Ui.polygon(f, "Teeth", points, Color3.fromRGB(246, 247, 248))
	local hole = Ui.frame(f, "Center", size * 0.32, size * 0.32, size * 0.36, size * 0.36, background)
	hole.ZIndex = 2
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(1, 0)
	round.Parent = hole
	return f
end
function Ui.gem(parent: Instance, x: number, y: number): Frame
	local f = Ui.frame(parent, "Gem", x, y, 46, 40, Color3.new())
	f.BackgroundTransparency = 1
	local a, b, c, d, e, tip =
		Vector2.new(0, 10),
		Vector2.new(10, 0),
		Vector2.new(35, 0),
		Vector2.new(46, 10),
		Vector2.new(23, 10),
		Vector2.new(23, 40)
	Ui.polygon(f, "TopLeft", { a, b, e }, Color3.fromRGB(117, 245, 255))
	Ui.polygon(f, "Top", { b, c, e }, Color3.fromRGB(38, 209, 255))
	Ui.polygon(f, "TopRight", { c, d, e }, Color3.fromRGB(84, 235, 255))
	Ui.polygon(f, "Left", { a, e, tip }, Color3.fromRGB(0, 172, 246))
	Ui.polygon(f, "Right", { e, d, tip }, Color3.fromRGB(0, 104, 210))
	return f
end
return table.freeze(Ui)
