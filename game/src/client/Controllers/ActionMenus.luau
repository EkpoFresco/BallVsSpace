--!strict
-- action-v1: presentation only. Catalog, equip events and server rules stay canonical.
local Catalog = require(game:GetService("ReplicatedStorage").Shared.AppearanceCatalog)
local Ui = require(script.Parent.ReferenceUi)
local Art = require(script.Parent.Artwork)
local Menus = {}
local theme = Ui.actionColors
local ink, surface, card, line = theme.ink, theme.surface, theme.card, theme.line
local paper, white, muted, cyan = theme.paper, theme.text, theme.muted, theme.cyan
local display, body = Ui.displayFont, Ui.cardFont
local function child(parent: Instance, name: string): GuiObject
	local node = parent:FindFirstChild(name)
	assert(node and node:IsA("GuiObject"), "Missing action menu node: " .. name)
	return node
end
local function box(node: GuiObject, x: number, y: number, w: number, h: number)
	node.Position = UDim2.fromOffset(x, y)
	node.Size = UDim2.fromOffset(w, h)
end
local function text(node: GuiObject, color: Color3, size: number, headline: boolean?)
	if node:IsA("TextLabel") or node:IsA("TextButton") then
		local label = node :: TextLabel
		label.FontFace = if headline then display else body
		label.TextColor3 = color
		label.TextSize = size
		label.TextStrokeTransparency = 1
		label.TextWrapped = true
		local outline = label:FindFirstChild("TextOutline")
		if outline and outline:IsA("UIStroke") then
			outline.Transparency = 1
		end
	end
end
local function button(node: GuiObject, color: Color3, foreground: Color3, size: number)
	local fill = node:FindFirstChild("ButtonFill")
	if fill and fill:IsA("Frame") then
		fill.BackgroundColor3 = Color3.new(1, 1, 1)
		local gradient = fill:FindFirstChildOfClass("UIGradient")
		if gradient then
			gradient.Color = ColorSequence.new(color)
		end
	end
	text(node, foreground, size, true)
	local caption = node:FindFirstChild("ButtonText")
	if caption and caption:IsA("TextLabel") then
		text(caption, foreground, size, true)
	end
	local stroke = node:FindFirstChild("Edge")
	if stroke and stroke:IsA("UIStroke") then
		stroke.Color = line
		stroke.Thickness = 1
	end
end
local function label(
	parent: Instance,
	name: string,
	value: string,
	color: Color3,
	size: number,
	headline: boolean?
): TextLabel
	local node = Ui.text(parent, name, value, 0, 0, 100, 24, size)
	text(node, color, size, headline)
	node.TextXAlignment = Enum.TextXAlignment.Left
	return node
end
local function tabs(window: Frame, names: { string }, selected: string)
	for _, name in names do
		button(
			child(window, name),
			if name == selected then cyan else card,
			if name == selected then ink else white,
			13
		)
	end
end
local inventoryTabs = { "Balls", "Explosions", "Flyers", "Fusion" }
local storeTabs = { "Events", "Balls", "Explosions", "Flyers" }
local pageNames = { "BallsPage", "PageExplosions", "PageFlyers", "PageFusion" }
function Menus.install(windows: { [string]: Frame }, open: (string) -> ())
	for _, name in { "Inventory", "Store" } do
		local window = windows[name]
		window:SetAttribute("Design", "action-v1")
		window.BackgroundColor3 = ink
		window.BackgroundTransparency = 0
		for _, node in window:GetDescendants() do
			if node:IsA("TextLabel") then
				text(node, white, node.TextSize)
			elseif node:IsA("UIStroke") then
				node.Color = line
			end
		end
		local header = Ui.frame(window, "ActionHeader", 0, 0, 100, 88, Color3.new(1, 1, 1))
		header.ClipsDescendants = true
		header.ZIndex = 1
		Ui.gradient(header, Color3.fromRGB(184, 11, 81), Color3.fromRGB(240, 42, 91), 10)
		for i = 1, 6 do
			local slash = Ui.frame(
				header,
				"Slash" .. i,
				i * 145 - 70,
				-65,
				if i % 2 == 0 then 28 else 56,
				220,
				Color3.fromRGB(255, 152, 181)
			)
			slash.Rotation = 32
			slash.BackgroundTransparency = 0.78
		end
		local ghost = label(header, "Ghost", string.upper(name), ink, 96, true)
		ghost.TextTransparency = 0.76
		box(ghost, 6, -19, 800, 115)
		local heading = child(window, "Heading") :: TextLabel
		heading.Text = string.upper(name)
		text(heading, white, 42, true)
		heading.ZIndex = 3
		local outline = heading:FindFirstChild("TextOutline") :: UIStroke?
		if outline then
			outline.Color = ink
			outline.Thickness = 3
			outline.Transparency = 0
		end
		button(child(window, "Close"), Color3.fromRGB(239, 39, 63), white, 25)
		local navigation = Ui.button(
			window,
			"SwitchMenu",
			if name == "Inventory" then "STORE  >" else "<  INVENTORY",
			0,
			0,
			120,
			44,
			surface
		)
		button(navigation, surface, white, 12)
		navigation.ZIndex = 4
		navigation.Activated:Connect(function()
			open(if name == "Inventory" then "Store" else "Inventory")
		end)
		local content = Instance.new("ScrollingFrame")
		content.Name = "Content"
		content.BackgroundTransparency = 1
		content.BorderSizePixel = 0
		content.ScrollBarThickness = 4
		content.ScrollBarImageColor3 = cyan
		content.ScrollingDirection = Enum.ScrollingDirection.Y
		content.Parent = window
		if name == "Inventory" then
			for i, pageName in pageNames do
				local page = child(window, pageName)
				page.Parent = content
				page.BackgroundColor3 = ink
				page.BackgroundTransparency = 0
				page:GetPropertyChangedSignal("Visible"):Connect(function()
					if page.Visible then
						tabs(window, inventoryTabs, inventoryTabs[i])
						content.CanvasPosition = Vector2.zero
					end
				end)
			end
			tabs(window, inventoryTabs, "Balls")
		else
			child(window, "Offers").Parent = content
			local balance = child(window, "Balance")
			balance.BackgroundTransparency = 1
			balance.ZIndex = 4
			tabs(window, storeTabs, "Events")
			for _, tabName in storeTabs do
				local tabButton = child(window, tabName) :: TextButton
				tabButton.Activated:Connect(function()
					tabs(window, storeTabs, tabName)
				end)
			end
		end
	end
	local inventory = windows.Inventory
	local content = child(inventory, "Content")
	local page = child(content, "BallsPage")
	local grid = child(page, "Grid") :: ScrollingFrame
	grid.ScrollingEnabled = false
	grid.ScrollBarThickness = 0
	grid.ClipsDescendants = false
	label(page, "CollectionTitle", "YOUR COLLECTION", white, 18, true)
	label(page, "Count", "12 appearances", muted, 12)
	for _, id in Catalog.ids do
		local item = child(grid, id)
		button(item, card, white, 12)
		local foot = child(item, "Footer")
		foot.BackgroundColor3 = surface
		child(foot, "Quantity").Visible = false
		label(item, "Selected", "SELECTED", ink, 11, true).BackgroundColor3 = cyan
		local equipped = label(item, "EquippedMark", "✓", ink, 13)
		equipped.BackgroundTransparency = 0
		equipped.BackgroundColor3 = paper
		equipped.TextXAlignment = Enum.TextXAlignment.Center
		equipped.ZIndex = 5
	end
	local detail = child(page, "Details")
	detail.BackgroundColor3 = paper
	local backdrop = Ui.frame(detail, "Showcase", 0, 0, 284, 268, paper)
	backdrop.ClipsDescendants = true
	backdrop.ZIndex = 0
	local light = Ui.frame(backdrop, "LightDiagonal", 155, -45, 44, 360, white)
	light.Rotation = 32
	light.BackgroundTransparency = 0.5
	child(detail, "Divider").Visible = false
	label(detail, "Kit", "DRIFT KIT", ink, 12)
	local state = label(detail, "State", "SELECTED", white, 12, true)
	state.BackgroundColor3 = ink
	state.BackgroundTransparency = 0
	state.TextXAlignment = Enum.TextXAlignment.Center
	text(child(detail, "Name"), ink, 31, true)
	text(child(detail, "Description"), Color3.fromRGB(70, 57, 71), 13)
	text(child(detail, "Equipped"), ink, 13)
	for _, name in { "Name", "Description", "Equipped" } do
		local target = child(detail, name) :: TextLabel
		target.TextXAlignment = Enum.TextXAlignment.Left
	end
	button(child(detail, "Equip"), cyan, ink, 17)
	local offers = child(child(windows.Store, "Content"), "Offers")
	offers.BackgroundColor3 = ink
	child(offers, "Title").Visible = false
	child(offers, "Availability").Visible = false
	for i, id in { "Laser", "Ray", "Balloons", "Parasol" } do
		local colors = {
			Color3.fromRGB(85, 66, 102),
			Color3.fromRGB(116, 67, 52),
			Color3.fromRGB(54, 80, 79),
			Color3.fromRGB(55, 78, 103),
		}
		button(child(offers, id), colors[i], white, 12)
		child(child(offers, id), "Foot").BackgroundColor3 = surface
		text(child(child(child(offers, id), "Foot"), "Name"), white, 20, true)
		button(child(offers, "View" .. id), cyan, ink, 13)
	end
	local feature = child(offers, "Spotlight")
	feature.BackgroundColor3 = cyan
	local gradient = feature:FindFirstChildOfClass("UIGradient")
	if gradient then
		gradient.Color = ColorSequence.new(cyan)
	end
	text(child(feature, "Tag"), ink, 11)
	local featureTag = child(feature, "Tag") :: TextLabel
	featureTag.Text = "THE BALL COLLECTION"
	text(child(feature, "Name"), ink, 37, true)
	local featureName = child(feature, "Name") :: TextLabel
	featureName.Text = "FIND YOUR\nNEXT FAVORITE."
	text(child(feature, "Caption"), ink, 13)
	local featureCaption = child(feature, "Caption") :: TextLabel
	featureCaption.Text = "12 ball appearances.\nYours to explore."
	Art.set(child(feature, "GlowBall") :: ImageLabel, "Verity", true)
	Art.image(feature, "Orbit", "Orbit", 0, 0, 88, 88, true)
	Art.image(feature, "Burst", "Burst", 0, 0, 72, 72, true)
	local explore = Ui.button(feature, "Explore", "EXPLORE BALLS  >", 0, 0, 200, 48, ink)
	button(explore, ink, white, 13)
	explore.Activated:Connect(function()
		open("Inventory")
		for i, pageName in pageNames do
			child(content, pageName).Visible = i == 1
		end
	end)
	for _, pageName in { "PageExplosions", "PageFlyers" } do
		for _, item in child(content, pageName):GetChildren() do
			if item:IsA("TextButton") then
				button(item, card, white, 17)
			end
		end
	end
end
function Menus.select(windows: { [string]: Frame }, selected: string, preferred: string)
	local page = child(child(windows.Inventory, "Content"), "BallsPage")
	local grid = child(page, "Grid")
	for _, id in Catalog.ids do
		local item = child(grid, id)
		local stroke = item:FindFirstChild("Edge") :: UIStroke
		stroke.Color = if id == selected then cyan else line
		stroke.Thickness = if id == selected then 2 else 1
		local foot = child(item, "Footer")
		foot.BackgroundColor3 = if id == selected then cyan else surface
		text(
			child(foot, "Name"),
			if id == selected then ink else white,
			(child(foot, "Name") :: TextLabel).TextSize
		)
		local marker = child(item, "Selected")
		marker.Visible = id == selected
		marker.BackgroundTransparency = 0
		marker.ZIndex = 4
		child(item, "EquippedMark").Visible = id == preferred
	end
	local detail = child(page, "Details")
	local target = child(detail, "Kit") :: TextLabel
	target.Text = string.upper(Catalog.entries[selected].kit) .. " KIT"
	local equip = child(detail, "Equip") :: TextButton
	equip.Text = if selected == preferred then "EQUIPPED  ✓" else "EQUIP BALL  >"
	button(equip, if selected == preferred then Color3.fromRGB(214, 208, 203) else cyan, ink, 17)
end
function Menus.layout(windows: { [string]: Frame }, viewport: Vector2, rootScale: number)
	local compact = viewport.Y < 600
	local width = math.min(1040, viewport.X - 24)
	local height = math.max(280, math.min(760, viewport.Y - (if compact then 16 else 48)))
	local headerHeight = if compact then 56 else 88
	local contentTop = headerHeight + 58
	local footerHeight = if compact then 8 else 54
	local visibleContentHeight = height - contentTop - footerHeight
	local contentHeight = visibleContentHeight
	local short = compact and contentHeight < 240
	local inner = width - 32
	for _, name in { "Inventory", "Store" } do
		local window = windows[name]
		window.Size = UDim2.fromOffset(width, height)
		local scale = window:FindFirstChildOfClass("UIScale") :: UIScale
		scale.Scale = 1 / rootScale
		box(child(window, "ActionHeader"), 0, 0, width, headerHeight)
		box(child(window, "Heading"), 18, 6, (if compact then width - 270 else width - 90), headerHeight - 12)
		text(child(window, "Heading"), white, if compact then 31 else 42, true)
		local titleStroke = child(window, "Heading"):FindFirstChild("TextOutline") :: UIStroke
		titleStroke.Transparency = 0
		box(child(window, "Close"), width - 60, (headerHeight - 44) / 2, 44, 44)
		box(child(window, "SwitchMenu"), width - 234, if compact then 6 else height - 48, 162, 44)
		if name == "Store" then
			local balance = child(window, "Balance")
			balance.Visible = not compact or width >= 680
			box(balance, if compact then width - 380 else width - 210, if compact then 15 else 31, 132, 26)
			box(child(balance, "Coin"), 0, 0, 24, 24)
			box(child(balance, "Coins"), 27, 0, 25, 26)
			box(child(balance, "Gem"), 70, 0, 24, 24)
			box(child(balance, "Gems"), 97, 0, 25, 26)
			text(child(balance, "Coins"), white, 13)
			text(child(balance, "Gems"), white, 13)
			local footer = child(window, "Footer") :: TextLabel
			footer.Visible = not compact
			box(footer, 16, height - 48, width - 260, 44)
			text(footer, muted, 13)
			footer.TextXAlignment = Enum.TextXAlignment.Left
		end
		local names: { string } = if name == "Inventory" then inventoryTabs else storeTabs
		local tabWidth = (inner - 24) / 4
		for i, tabName in names do
			local tab = child(window, tabName) :: TextButton
			box(tab, 16 + (i - 1) * (tabWidth + 8), headerHeight + 6, tabWidth, 44)
			box(child(tab, "TabArt"), 7, 7, 28, 28)
			local caption = child(tab, "ButtonText") :: TextLabel
			caption.Position = UDim2.fromOffset(38, 0)
			caption.Size = UDim2.new(1, -42, 1, 0)
			tab.TextYAlignment = Enum.TextYAlignment.Center
		end
		box(child(window, "Content"), 16, contentTop, inner, visibleContentHeight)
	end
	local content = child(windows.Inventory, "Content") :: ScrollingFrame
	local page = child(content, "BallsPage")
	local detailWidth = if compact then 242 else 284
	local gridWidth = inner - detailWidth - 16
	local columns = math.clamp(math.floor((gridWidth + 10) / 100), 2, 4)
	local cardWidth = (gridWidth - 4 - (columns - 1) * 10) / columns
	local cardHeight = if compact then 112 else math.min(160, cardWidth + 36)
	local gridHeight = math.ceil(#Catalog.ids / columns) * (cardHeight + 10)
	local detailHeight = contentHeight
	local pageHeight = contentHeight
	box(page, 0, 0, inner, pageHeight)
	local countVisible = gridWidth >= 380
	child(page, "Count").Visible = countVisible
	box(child(page, "CollectionTitle"), 0, 0, gridWidth - (if countVisible then 104 else 0), 26)
	text(child(page, "CollectionTitle"), white, if compact then 14 else 18, true)
	box(child(page, "Count"), gridWidth - 104, 0, 104, 26)
	local grid = child(page, "Grid") :: ScrollingFrame
	box(grid, 2, 34, gridWidth - 4, contentHeight - 36)
	grid.CanvasSize = UDim2.fromOffset(0, gridHeight)
	grid.ScrollingEnabled = gridHeight > contentHeight - 36
	grid.ClipsDescendants = true
	grid.ScrollBarThickness = if grid.ScrollingEnabled then 4 else 0
	for i, id in Catalog.ids do
		local item = child(grid, id)
		box(
			item,
			(i - 1) % columns * (cardWidth + 10),
			math.floor((i - 1) / columns) * (cardHeight + 10),
			cardWidth,
			cardHeight
		)
		local size = math.min(104, cardWidth - 12, cardHeight - 44)
		local portrait = child(item, "PortraitArt")
		box(portrait, (cardWidth - size) / 2, 10, size, size)
		box(child(portrait, "Ball"), 0, 0, size, size)
		local weapon = portrait:FindFirstChild("Weapon")
		if weapon and weapon:IsA("ImageLabel") then
			box(weapon, size * 0.61, size * 0.47, size * 0.39, size * 0.53)
		end
		local foot = child(item, "Footer")
		box(foot, 0, cardHeight - 34, cardWidth, 34)
		box(child(foot, "Name"), 6, 0, cardWidth - 12, 34)
		text(child(foot, "Name"), (child(foot, "Name") :: TextLabel).TextColor3, if compact then 12 else 14)
		box(child(item, "Selected"), cardWidth - 74, 0, 74, 20)
		box(child(item, "EquippedMark"), 4, 25, 19, 19)
	end
	local detail = child(page, "Details")
	box(detail, gridWidth + 16, 0, detailWidth, detailHeight)
	local compactDetail = compact or contentHeight < 520
	local artSize = if compactDetail then math.min(220, math.max(60, detailHeight - 180)) else 220
	box(child(detail, "Showcase"), 0, 0, detailWidth, if compactDetail then artSize + 22 else 268)
	box(
		child(detail, "Ball"),
		(detailWidth - artSize) / 2,
		if compactDetail then 10 else 38,
		artSize,
		artSize
	)
	box(
		child(detail, "Weapon"),
		detailWidth / 2 + artSize * 0.14,
		if compactDetail then artSize * 0.35 else 148,
		artSize * 0.39,
		artSize * 0.46
	)
	box(child(detail, "State"), 8, 8, 84, 20)
	local copyY = if compactDetail then detailHeight - 163 else 278
	local copyWidth = detailWidth - 32
	box(child(detail, "Kit"), 16, copyY, copyWidth, if compactDetail then 16 else 20)
	box(
		child(detail, "Name"),
		16,
		copyY + (if compactDetail then 18 else 27),
		copyWidth,
		if compactDetail then 32 else 66
	)
	text(child(detail, "Name"), ink, if compactDetail then 23 else 31, true)
	box(
		child(detail, "Description"),
		16,
		if compactDetail then detailHeight - 105 else copyY + 98,
		copyWidth,
		if compactDetail then 32 else 54
	)
	text(child(detail, "Description"), Color3.fromRGB(70, 57, 71), 13)
	box(child(detail, "Equipped"), 16, detailHeight - 70, copyWidth, 20)
	box(child(detail, "Equip"), 16, detailHeight - 48, copyWidth, 44)
	child(detail, "State").Visible = not short
	if short then
		-- Keep selection, description and Equip fixed while only the collection scrolls.
		box(child(detail, "Showcase"), 0, 0, detailWidth, 70)
		box(child(detail, "Ball"), detailWidth - 72, 6, 60, 60)
		box(child(detail, "Weapon"), detailWidth - 40, 30, 24, 28)
		box(child(detail, "Kit"), 12, 4, detailWidth - 96, 18)
		box(child(detail, "Name"), 12, 22, detailWidth - 96, 48)
		text(child(detail, "Name"), ink, 18, true)
		box(child(detail, "Description"), 12, 72, detailWidth - 24, detailHeight - 146)
		box(child(detail, "Equipped"), 12, detailHeight - 70, detailWidth - 24, 20)
	end
	for _, pageName in { "PageExplosions", "PageFlyers", "PageFusion" } do
		local other = child(content, pageName)
		box(other, 0, 0, inner, contentHeight)
		if pageName == "PageFusion" then
			local size = if short then 52 elseif compact then 76 else 120
			box(child(other, "FusionArt"), inner / 2 - size / 2, 12, size, size)
			box(child(other, "Title"), 16, if short then 68 elseif compact then 98 else 180, inner - 32, 38)
			box(child(other, "Body"), 20, if short then 108 elseif compact then 142 else 254, inner - 40, 68)
		else
			local ids: { string } = if pageName == "PageFlyers"
				then { "Ufo", "Balloons", "Parasol" }
				else { "Explosion", "Spark", "Ring" }
			local w = (inner - 24) / 3
			local h = if compact then contentHeight - 40 else 188
			for i, id in ids do
				local preview = child(other, id)
				box(preview, (i - 1) * (w + 12), 0, w, h)
				local size = math.min(112, h - 52)
				box(child(preview, "Art"), w / 2 - size / 2, 10, size, size)
			end
			box(child(other, "Caption"), 0, if compact then contentHeight - 34 else 220, inner, 28)
		end
	end
	content.CanvasSize = UDim2.fromOffset(0, contentHeight)
	content.ScrollingEnabled = false
	local storeContent = child(windows.Store, "Content") :: ScrollingFrame
	local offers = child(storeContent, "Offers")
	local featureWidth = if compact then 222 else 254
	local storeVisibleHeight = contentHeight
	local storeBodyHeight = if compact then math.max(240, contentHeight) else contentHeight
	local compactStore = compact or storeBodyHeight < 500
	local featureHeight = storeBodyHeight
	local startX = featureWidth + 16
	local offerWidth = (inner - startX - 14) / 2
	local offerHeight = (storeBodyHeight - (if compactStore then 10 else 14)) / 2
	local gap = if compactStore then 10 else 14
	local storeHeight = offerHeight * 2 + gap
	box(offers, 0, 0, inner, storeHeight)
	local feature = child(offers, "Spotlight")
	box(feature, 0, 0, featureWidth, featureHeight)
	box(child(feature, "Tag"), 12, 8, featureWidth - 24, 20)
	box(
		child(feature, "Name"),
		12,
		if compactStore then 32 else 50,
		featureWidth - 24,
		if compactStore then 72 else 145
	)
	text(child(feature, "Name"), ink, if compactStore then 25 else 37, true)
	local heroSize = if compactStore then math.max(55, featureHeight - 196) else 155
	box(
		child(feature, "GlowBall"),
		featureWidth / 2 - heroSize / 2,
		if compactStore then 106 else 183,
		heroSize,
		heroSize
	)
	box(
		child(feature, "Orbit"),
		12,
		if compactStore then 116 else 295,
		if compactStore then 48 else 88,
		if compactStore then 48 else 88
	)
	box(
		child(feature, "Burst"),
		featureWidth - (if compactStore then 52 else 84),
		if compactStore then 122 else 302,
		if compactStore then 42 else 72,
		if compactStore then 42 else 72
	)
	box(child(feature, "Caption"), 12, featureHeight - 90, featureWidth - 24, 34)
	text(child(feature, "Caption"), ink, if compactStore then 11 else 13)
	box(child(feature, "Explore"), 12, featureHeight - 48, featureWidth - 24, 44)
	for i, id in { "Laser", "Ray", "Balloons", "Parasol" } do
		local x = startX + (i - 1) % 2 * (offerWidth + 14)
		local y = math.floor((i - 1) / 2) * (offerHeight + gap)
		local offer = child(offers, id)
		local artHeight = offerHeight - (if compactStore then 78 else 100)
		box(offer, x, y, offerWidth, offerHeight - 48)
		local size = math.min(138, offerWidth - 16, artHeight)
		box(child(offer, "Art"), (offerWidth - size) / 2, 0, size, size)
		local foot = child(offer, "Foot")
		box(foot, 0, artHeight, offerWidth, if compactStore then 28 else 52)
		box(child(foot, "Name"), 8, 0, offerWidth - 16, if compactStore then 28 else 52)
		text(child(foot, "Name"), white, if compactStore then 15 else 20, true)
		box(child(offers, "View" .. id), x + 6, y + offerHeight - 44, offerWidth - 12, 44)
	end
	storeContent.CanvasSize = UDim2.fromOffset(0, storeHeight)
	storeContent.ScrollingEnabled = storeBodyHeight > storeVisibleHeight
end
return table.freeze(Menus)
