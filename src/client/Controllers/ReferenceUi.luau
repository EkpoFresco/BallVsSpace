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
	for _, offset in { Vector2.new(0.08, 0), Vector2.new(0.46, 0) } do
		local c = Ui.frame(f, "Lobe", 0, 0, 1, 1, Color3.fromRGB(225, 27, 63))
		c.Position = UDim2.fromScale(offset.X, offset.Y)
		c.Size = UDim2.fromScale(0.5, 0.52)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = c
	end
	local point = Ui.frame(f, "Point", 0, 0, 1, 1, Color3.fromRGB(225, 27, 63))
	point.Size = UDim2.fromScale(0.58, 0.58)
	point.Position = UDim2.fromScale(0.21, 0.24)
	point.Rotation = 45
	return f
end
return table.freeze(Ui)
