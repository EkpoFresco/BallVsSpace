--!strict
local TweenService = game:GetService("TweenService")
local Artwork = require(script.Parent.Artwork)
local Ui = {}
Ui.displayFont =
	Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Heavy, Enum.FontStyle.Italic)
Ui.cardFont = Font.new("rbxasset://fonts/families/Montserrat.json", Enum.FontWeight.Regular)
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
	stroke.Thickness = if display then 1.65 else 1.3
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
	edge.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	edge.Color = color:Lerp(Color3.new(0, 0, 0), 0.6)
	edge.Thickness = 2
	-- Render the inset border above fills/footers; otherwise children cover it.
	local outline = Ui.frame(b, "Outline", 0, 0, w, h, Color3.new())
	outline.BackgroundTransparency = 1
	outline.Size = UDim2.fromScale(1, 1)
	outline.ZIndex = 6
	edge.Parent = outline
	local hover = false
	local function tint(brightness: number)
		TweenService:Create(
			background,
			TweenInfo.new(0.12),
			{ BackgroundColor3 = Color3.new(brightness, brightness, brightness) }
		):Play()
	end
	b.MouseEnter:Connect(function()
		hover = true
		tint(1)
	end)
	b.MouseLeave:Connect(function()
		hover = false
		tint(0.94)
	end)
	b.MouseButton1Down:Connect(function()
		tint(0.78)
	end)
	b.MouseButton1Up:Connect(function()
		tint(if hover then 1 else 0.94)
	end)
	background.BackgroundColor3 = Color3.new(0.94, 0.94, 0.94)
	return b
end
function Ui.gear(parent: Instance, x: number, y: number, size: number, _background: Color3): Frame
	local f = Ui.frame(parent, "GearIcon", x, y, size, size, Color3.new())
	f.BackgroundTransparency = 1
	f.ZIndex = 3
	Artwork.image(f, "Teeth", "Gear", 0, 0, size, size)
	return f
end
function Ui.gem(parent: Instance, x: number, y: number): Frame
	local f = Ui.frame(parent, "Gem", x, y, 46, 40, Color3.new())
	f.BackgroundTransparency = 1
	Artwork.image(f, "Facets", "Gem", 0, 0, 46, 40)
	return f
end
Ui.actionColors = table.freeze({
	ink = Color3.fromRGB(16, 13, 20),
	surface = Color3.fromRGB(33, 28, 37),
	card = Color3.fromRGB(48, 43, 52),
	line = Color3.fromRGB(100, 88, 102),
	text = Color3.fromRGB(255, 249, 244),
	muted = Color3.fromRGB(196, 187, 197),
	paper = Color3.fromRGB(237, 230, 221),
	cyan = Color3.fromRGB(142, 239, 229),
	crimson = Color3.fromRGB(184, 11, 81),
	pink = Color3.fromRGB(240, 42, 91),
	close = Color3.fromRGB(239, 39, 63),
})
local primaryActions = {
	Left = true,
	Right = true,
	Primary = true,
	Explore = true,
	Confirm = true,
	Invite = true,
	["1v1"] = true,
	Practice = true,
}
local preserveColor = { ScoreA = true, ScoreB = true, BarA = true, BarB = true, PlayerName = true }
function Ui.actionTheme(root: Instance, skip: { [string]: boolean }?)
	local c = Ui.actionColors
	local function visit(item: Instance)
		if skip and skip[item.Name] then
			return
		end
		if item:IsA("ViewportFrame") or item:IsA("WorldModel") then
			return
		end
		if item:IsA("TextLabel") then
			local heading = item.Name == "Heading"
				or item.Name == "Title"
				or item.Name == "Headline"
				or item.Name == "ResultTitle"
			if heading then
				item.FontFace = Ui.displayFont
			end
			if not preserveColor[item.Name] then
				item.TextColor3 = c.text
			end
			local outline = item:FindFirstChild("TextOutline")
			if outline and outline:IsA("UIStroke") then
				outline.Transparency = if heading then 0.25 else 1
			end
			if item.BackgroundTransparency < 1 then
				item.BackgroundColor3 = c.surface
			end
		elseif item:IsA("TextButton") then
			local color = if item.Name == "Close"
				then c.close
				elseif primaryActions[item.Name] then c.cyan
				else c.card
			item.BackgroundColor3 = color
			local fill = item:FindFirstChild("ButtonFill")
			if fill and fill:IsA("Frame") then
				local gradient = fill:FindFirstChildOfClass("UIGradient")
				if gradient then
					gradient.Color = ColorSequence.new(color, color:Lerp(c.ink, 0.08))
				end
			end
			local edge = item:FindFirstChild("Edge", true)
			if edge and edge:IsA("UIStroke") then
				edge.Color = c.line
				edge.Thickness = 1
			end
		elseif
			item:IsA("Frame")
			and item.Name ~= "ButtonFill"
			and item.BackgroundTransparency < 1
			and not preserveColor[item.Name]
		then
			item.BackgroundColor3 = if item.Name == "Stripe"
				then c.crimson
				elseif item.Name == "PreviewBackground" then c.paper
				elseif item.Name == "CardDivider" then c.line
				else c.surface
			local gradient = item:FindFirstChildOfClass("UIGradient")
			if gradient and item.Name ~= "ButtonFill" then
				gradient.Color = ColorSequence.new(c.card, c.surface)
			end
		elseif item:IsA("UIStroke") and item.ApplyStrokeMode == Enum.ApplyStrokeMode.Border then
			item.Color = c.line
			item.Thickness = math.min(2, item.Thickness)
		end
		for _, child in item:GetChildren() do
			visit(child)
		end
		if item:IsA("TextButton") and primaryActions[item.Name] then
			local caption = item:FindFirstChild("ButtonText")
			if caption and caption:IsA("TextLabel") then
				caption.TextColor3 = c.ink
			end
		end
	end
	visit(root)
end
function Ui.actionHeader(parent: GuiObject, height: number): Frame
	local c = Ui.actionColors
	local band = Ui.frame(parent, "ThemeHeader", 0, 0, 1, height, c.crimson)
	band.Size = UDim2.new(1, 0, 0, height)
	band.ClipsDescendants = true
	band.ZIndex = 0
	Ui.gradient(band, c.crimson, c.pink, 0)
	for i = 1, 4 do
		local stripe = Ui.frame(band, "Diagonal", 0, -height, 26, height * 3, c.text)
		stripe.Position = UDim2.new(i / 5, 0, 0, -height)
		stripe.Rotation = 28
		stripe.BackgroundTransparency = 0.9
		stripe.ZIndex = 0
	end
	return band
end
return table.freeze(Ui)
