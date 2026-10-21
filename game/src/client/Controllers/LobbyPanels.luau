--!strict
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Catalog = require(game:GetService("ReplicatedStorage").Shared.AppearanceCatalog)
local Heroes = require(game:GetService("ReplicatedStorage").Shared.HeroDefinitions)
local Ui = require(script.Parent.ReferenceUi)
local Art = require(script.Parent.Artwork)
local ActionMenus = require(script.Parent.ActionMenus)
local Panels = {}
export type State = {
	layer: Frame,
	shade: TextButton,
	windows: { [string]: Frame },
	scales: { UIScale },
	active: string,
	selected: string,
	equip: BindableEvent,
	play: BindableEvent,
	toast: TextLabel,
	toastVersion: number,
	toastTween: Tween?,
	openTween: Tween?,
	detailName: TextLabel,
	detailText: TextLabel,
	detailImage: ImageLabel,
	detailWeapon: ImageLabel,
	equipped: TextLabel,
	tabs: { TextButton },
	inventoryPages: { Frame },
	storePages: { Frame },
	preferred: string,
	layoutSize: Vector2,
	base: { [GuiObject]: { size: UDim2, position: UDim2, textSize: number? } },
}
local blue = Color3.fromRGB(45, 139, 218)
local gold = Color3.fromRGB(255, 184, 0)
local purple = Color3.fromRGB(157, 70, 236)
local function event(parent: Instance, name: string): BindableEvent
	local e = Instance.new("BindableEvent")
	e.Name = name
	e.Parent = parent
	return e
end
local function edge(parent: Instance, color: Color3, thickness: number)
	local s = Instance.new("UIStroke")
	s.Color = color
	s.Thickness = thickness
	s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	s.BorderStrokePosition = Enum.BorderStrokePosition.Inner
	s.Parent = parent
end
function Panels.notify(s: State, message: string)
	if s.toastTween then
		s.toastTween:Cancel()
		s.toastTween = nil
	end
	s.toastVersion += 1
	local version = s.toastVersion
	s.toast.Text = message
	s.toast.Visible = true
	s.toast.TextTransparency = 0
	task.delay(3.5, function()
		if s.toast.Parent and s.toastVersion == version then
			local tween = TweenService:Create(s.toast, TweenInfo.new(0.2), { TextTransparency = 1 })
			s.toastTween = tween
			tween:Play()
			task.delay(0.2, function()
				if s.toast.Parent and s.toastVersion == version then
					s.toast.Visible = false
				end
			end)
		end
	end)
end
function Panels.close(s: State)
	if s.openTween then
		s.openTween:Cancel()
		s.openTween = nil
	end
	s.active = ""
	s.layer.Visible = false
	for _, w in s.windows do
		w.Visible = false
		(w:FindFirstChild("Close") :: GuiButton).Visible = false
	end
end
function Panels.open(s: State, name: string)
	if s.active == name then
		Panels.close(s)
		return
	end
	Panels.close(s)
	local window = s.windows[name]
	if not window then
		return
	end
	s.active = name
	s.layer.Visible = true
	window.Visible = true
	-- Reintroduce the close control after the new parent has a rendered layout.
	-- Simultaneous parent/child visibility changes can retain a stale culled subtree.
	local close = window:FindFirstChild("Close") :: GuiButton
	task.defer(function()
		task.wait()
		if window.Parent and s.active == name and window.Visible then
			close.Visible = true
		end
	end)
	local center = UDim2.fromOffset(s.layer.Size.X.Offset / 2, 303)
	window.Position = center
	if s.layer:GetAttribute("ReducedMotion") ~= true then
		window.Position = center + UDim2.fromOffset(0, 8)
		local tween = TweenService:Create(
			window,
			TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = center }
		)
		s.openTween = tween
		tween:Play()
	end
end
local function tab(
	parent: Instance,
	name: string,
	icon: string,
	x: number,
	width: number,
	color: Color3,
	ball: boolean?
): TextButton
	local b = Ui.button(parent, name, name, x, 66, width, 50, color)
	b.TextSize = 19
	b.TextYAlignment = Enum.TextYAlignment.Bottom
	Art.image(b, "TabArt", icon, width / 2 - 26, -9, 52, 52, ball)
	local text = b:FindFirstChild("ButtonText") :: TextLabel
	text.FontFace = Ui.cardFont
	text.ZIndex = 3
	return b
end
local function window(s: State, name: string, width: number, height: number): Frame
	local w = Ui.frame(s.layer, name, 401.5, 303, width, height, Color3.fromRGB(8, 18, 30))
	w.AnchorPoint = Vector2.new(0.5, 0.5)
	w.BackgroundTransparency = 0
	w.Active = true
	w.Visible = false
	w.ZIndex = 2
	-- A Frame does not consume clicks destined for the backdrop GuiButton.
	local catch = Instance.new("TextButton")
	catch.Name = "ModalSurface"
	catch.Text = ""
	catch.BackgroundTransparency = 1
	catch.AutoButtonColor = false
	catch.Selectable = false
	catch.Size = UDim2.fromScale(1, 1)
	catch.ZIndex = 0
	catch.Parent = w
	edge(w, Color3.fromRGB(75, 130, 195), 1)
	local scale = Instance.new("UIScale")
	scale.Parent = w
	table.insert(s.scales, scale)
	local title = Ui.text(w, "Heading", name, 20, 4, width - 60, 53, 36, true)
	title.TextXAlignment = Enum.TextXAlignment.Left
	local close = Ui.button(w, "Close", "", width - 20, -14, 46, 46, Color3.fromRGB(133, 137, 144))
	local cross = Ui.text(close, "Cross", "×", 0, 0, 46, 46, 30, true)
	cross.Size = UDim2.fromScale(1, 1)
	cross.ZIndex = 3
	(cross:FindFirstChild("TextOutline") :: UIStroke).Transparency = 1
	close.ZIndex = 5
	close.Visible = false
	close.Activated:Connect(function()
		Panels.close(s)
	end)
	s.windows[name] = w
	return w
end
function Panels.select(s: State, id: string)
	local entry = Catalog.entries[id]
	if not entry then
		return
	end
	s.selected = id
	s.detailName.Text = entry.name
	s.detailText.Text = Heroes.heroes[id].ability
	Art.set(s.detailImage, id, true)
	s.detailWeapon.Visible = false
	if s.detailWeapon.Visible then
		Art.set(s.detailWeapon, id)
	end
	if s.windows.Inventory:FindFirstChild("Content") then
		ActionMenus.select(s.windows, s.selected, s.preferred)
	end
end
function Panels.new(parent: Instance): State
	local layer = Ui.frame(parent, "Panels", 0, 0, 803, 602, Color3.new())
	layer.BackgroundTransparency = 1
	layer.ZIndex = 20
	layer.Visible = false
	local shade = Instance.new("TextButton")
	shade.Name = "Dismiss"
	shade.Text = ""
	shade.AutoButtonColor = false
	shade.Position = UDim2.fromOffset(-800, -800)
	shade.Size = UDim2.fromOffset(2403, 2202)
	shade.BackgroundColor3 = Color3.new()
	shade.BackgroundTransparency = 0.46
	shade.BorderSizePixel = 0
	shade.Parent = layer
	local toast = Ui.text(parent, "Toast", "", 201, 518, 401, 44, 15)
	toast.BackgroundColor3 = Color3.fromRGB(11, 22, 38)
	toast.BackgroundTransparency = 0.08
	toast.ZIndex = 50
	toast.Visible = false
	edge(toast, Color3.fromRGB(96, 158, 217), 1)
	local s: State = {
		layer = layer,
		shade = shade,
		windows = {},
		scales = {},
		active = "",
		selected = "Astra",
		equip = event(layer, "EquipRequested"),
		play = event(layer, "PlayRequested"),
		toast = toast,
		toastVersion = 0,
		detailName = Instance.new("TextLabel"),
		detailText = Instance.new("TextLabel"),
		detailImage = Instance.new("ImageLabel"),
		detailWeapon = Instance.new("ImageLabel"),
		equipped = Instance.new("TextLabel"),
		tabs = {},
		inventoryPages = {},
		storePages = {},
		preferred = "Astra",
		layoutSize = Vector2.zero,
		base = {},
	}
	-- Replace temporary typed handles during construction; they never enter the DataModel.
	s.detailName:Destroy()
	s.detailText:Destroy()
	s.detailImage:Destroy()
	s.detailWeapon:Destroy()
	s.equipped:Destroy()
	shade.Activated:Connect(function()
		Panels.close(s)
	end)
	local inventory = window(s, "Inventory", 600, 430)
	for i, definition in
		{
			{ name = "Balls", icon = "Runa", color = gold },
			{ name = "Explosions", icon = "Explosion", color = purple },
			{ name = "Flyers", icon = "Ufo", color = Color3.fromRGB(237, 62, 120) },
			{ name = "Fusion", icon = "Fusion", color = blue },
		}
	do
		local b = tab(
			inventory,
			definition.name,
			definition.icon,
			13 + (i - 1) * 145,
			139,
			definition.color,
			i == 1
		)
		table.insert(s.tabs, b)
	end
	local inventoryBody = Ui.frame(inventory, "BallsPage", 10, 126, 580, 292, Color3.fromRGB(19, 22, 39))
	inventoryBody.BackgroundTransparency = 0.15
	table.insert(s.inventoryPages, inventoryBody)
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "Grid"
	grid.Position = UDim2.fromOffset(0, 0)
	grid.Size = UDim2.fromOffset(429, 292)
	grid.CanvasSize = UDim2.fromOffset(0, 4 * 139)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 7
	grid.ScrollBarImageColor3 = Color3.fromRGB(151, 153, 164)
	grid.Parent = inventoryBody
	for i, id in Catalog.ids do
		local b = Ui.button(
			grid,
			id,
			"",
			(i - 1) % 3 * 141,
			math.floor((i - 1) / 3) * 139,
			134,
			134,
			Color3.fromRGB(4, 20, 33)
		)
		Art.portrait(b, id, 6, 0, 122)
		local foot = Ui.frame(b, "Footer", 0, 112, 134, 22, Color3.fromRGB(51, 77, 123))
		local title = Ui.text(foot, "Name", id, 3, 0, 113, 22, if id == "Vaska" then 10 else 13)
		title.TextXAlignment = Enum.TextXAlignment.Left
		Ui.text(foot, "Quantity", "x1", 111, 0, 21, 22, 12)
		b.Activated:Connect(function()
			Panels.select(s, id)
		end)
	end
	local details = Ui.frame(inventoryBody, "Details", 437, 0, 143, 292, Color3.fromRGB(25, 27, 43))
	s.detailName = Ui.text(details, "Name", "", 2, 4, 139, 32, 18)
	s.detailImage = Art.image(details, "Ball", "Astra", 19, 35, 104, 104, true)
	s.detailWeapon = Art.image(details, "Weapon", "Bram", 51, 23, 43, 71)
	s.detailText = Ui.text(details, "Description", "", 8, 143, 127, 65, 12)
	Ui.frame(details, "Divider", 9, 211, 125, 1, Color3.fromRGB(107, 134, 188))
	s.equipped = Ui.text(details, "Equipped", "Equipped: Astra", 5, 217, 133, 21, 11)
	local equip = Ui.button(details, "Equip", "Equip", 9, 246, 125, 35, Color3.fromRGB(0, 165, 232))
	equip.TextSize = 18
	equip.Activated:Connect(function()
		s.preferred = s.selected
		s.equipped.Text = "Equipped: " .. s.selected
		s.equip:Fire(s.selected)
		ActionMenus.select(s.windows, s.selected, s.preferred)
		Panels.notify(s, Catalog.entries[s.selected].name .. " selected")
	end)
	for _, category in { "Explosions", "Flyers", "Fusion" } do
		local p = Ui.frame(inventory, "Page" .. category, 10, 126, 580, 292, Color3.fromRGB(19, 22, 39))
		p.Visible = false
		table.insert(s.inventoryPages, p)
		if category == "Fusion" then
			Art.image(p, "FusionArt", "Fusion", 232, 25, 116, 116)
			Ui.text(p, "Title", "Build your collection", 50, 153, 480, 35, 24)
			Ui.text(
				p,
				"Body",
				"Every hero is available to explore.\nChoose your next look from the Balls tab.",
				60,
				195,
				460,
				58,
				17
			)
		else
			local options: { string } = if category == "Flyers"
				then { "Ufo", "Balloons", "Parasol" }
				else { "Explosion", "Spark", "Ring" }
			for j, icon in options do
				local card = Ui.button(
					p,
					icon,
					"Preview",
					15 + (j - 1) * 188,
					14,
					175,
					207,
					if category == "Flyers" then Color3.fromRGB(39, 62, 95) else Color3.fromRGB(56, 33, 91)
				)
				Art.image(card, "Art", icon, 24, 12, 127, 127)
				card.TextYAlignment = Enum.TextYAlignment.Bottom
				card.TextSize = 17
				card.Activated:Connect(function()
					local art = card:FindFirstChild("Art") :: ImageLabel
					art.Rotation = 0
					if s.layer:GetAttribute("ReducedMotion") ~= true then
						TweenService:Create(
							art,
							TweenInfo.new(0.65, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
							{ Rotation = 360 }
						):Play()
					end
					Panels.notify(s, if category == "Flyers" then "Flyer preview" else "Effect preview")
				end)
			end
			Ui.text(p, "Caption", "Cosmetic previews", 20, 242, 540, 30, 17, true)
		end
	end
	for i, b in s.tabs do
		b.Activated:Connect(function()
			for j, p in s.inventoryPages do
				p.Visible = i == j
			end
		end)
	end
	local store = window(s, "Store", 700, 502)
	local storeBalance = Ui.frame(store, "Balance", 308, 10, 340, 42, Color3.fromRGB(10, 37, 58))
	Art.image(storeBalance, "Coin", "Coin", 0, -4, 48, 48)
	Ui.text(storeBalance, "Coins", "0", 51, 0, 93, 40, 27, true)
	Art.image(storeBalance, "Gem", "Gem", 171, -4, 48, 48)
	Ui.text(storeBalance, "Gems", "0", 225, 0, 75, 40, 27, true)
	for i, d in
		{
			{ name = "Events", icon = "Events", color = blue },
			{ name = "Balls", icon = "Runa", color = gold },
			{ name = "Explosions", icon = "Explosion", color = purple },
			{ name = "Flyers", icon = "Ufo", color = Color3.fromRGB(237, 62, 120) },
		}
	do
		local b = tab(store, d.name, d.icon, 18 + (i - 1) * 168, 160, d.color, i == 2)
		b.Activated:Connect(function()
			if i == 1 or i == 2 then
				for j, p in s.storePages do
					p.Visible = j == 1
				end
			else
				Panels.open(s, "Inventory")
				for j, p in s.inventoryPages do
					p.Visible = j == i - 1
				end
			end
		end)
	end
	local offers = Ui.frame(store, "Offers", 16, 130, 668, 345, Color3.fromRGB(18, 35, 58))
	table.insert(s.storePages, offers)
	edge(offers, Color3.fromRGB(91, 167, 228), 1)
	local title = Ui.text(offers, "Title", "Daily Store", 12, 4, 330, 32, 25, true)
	title.TextXAlignment = Enum.TextXAlignment.Left
	Ui.text(offers, "Availability", "Free collection", 457, 8, 198, 24, 14)
	for i, item in
		{
			{ id = "Cira", name = "Cira Mirrorwake", ball = true },
			{ id = "Ravi", name = "Ravi Sunwheel", ball = true },
			{ id = "Balloons", name = "Colorful Balloon", ball = false },
			{ id = "Parasol", name = "Blue Parasol", ball = false },
		}
	do
		local id = item.id
		local card = Ui.button(offers, id, "", 10 + (i - 1) * 164, 43, 156, 135, Color3.fromRGB(29, 47, 75))
		Art.image(card, "Art", id, 24, 2, 108, 108, item.ball)
		local foot = Ui.frame(card, "Foot", 0, 108, 156, 27, Color3.fromRGB(51, 77, 115))
		Ui.text(foot, "Name", item.name, 3, 0, 150, 27, 14)
		local action = Ui.button(
			offers,
			"View" .. id,
			if item.ball then "View Ball" else "Preview",
			10 + (i - 1) * 164,
			181,
			156,
			31,
			if item.ball then Color3.fromRGB(88, 216, 0) else gold
		)
		action.TextSize = 14
		local function inspect()
			Panels.open(s, "Inventory")
			for j, p in s.inventoryPages do
				p.Visible = j == (if item.ball then 1 else 3)
			end
			if item.ball then
				Panels.select(s, id)
			end
		end
		card.Activated:Connect(inspect)
		action.Activated:Connect(inspect)
	end
	local bundle = Ui.frame(offers, "Spotlight", 10, 229, 648, 105, Color3.fromRGB(19, 13, 54))
	Ui.gradient(bundle, Color3.fromRGB(52, 25, 104), Color3.fromRGB(8, 19, 35), 0)
	local sub = Ui.text(bundle, "Tag", "COLLECTION SPOTLIGHT", 12, 7, 320, 21, 12)
	sub.TextXAlignment = Enum.TextXAlignment.Left
	local headline = Ui.text(bundle, "Name", "Find your next favorite", 12, 29, 440, 35, 25)
	headline.TextXAlignment = Enum.TextXAlignment.Left
	Ui.text(bundle, "Caption", "30 original heroes • Yours to explore", 12, 70, 400, 23, 14)
	Art.image(bundle, "GlowBall", "Cira", 492, -6, 119, 119, true)
	Ui.text(store, "Footer", "All heroes are free. No purchase needed.", 30, 477, 640, 22, 12)
	local rewards = window(s, "Rewards", 420, 340)
	Art.image(rewards, "Gift", "Gift", 168, 71, 84, 84)
	Ui.text(rewards, "Headline", "Your collection starts here", 25, 170, 370, 38, 23)
	Ui.text(
		rewards,
		"Body",
		"Explore every look, choose your ball,\nand take it into the arena.",
		30,
		216,
		360,
		56,
		17
	)
	local collect = Ui.button(rewards, "Explore", "Explore Balls", 98, 285, 224, 38, gold)
	collect.Activated:Connect(function()
		Panels.open(s, "Inventory")
		for i, p in s.inventoryPages do
			p.Visible = i == 1
		end
	end)
	local modes = window(s, "Play", 460, 326)
	for i, mode in { "1v1", "Practice" } do
		local b = Ui.button(
			modes,
			mode,
			mode,
			24 + (i - 1) * 218,
			91,
			194,
			171,
			if i == 1 then blue else Color3.fromRGB(130, 106, 190)
		)
		Art.image(b, "Ball", if i == 1 then "Bram" else "Astra", 42, 5, 110, 110, true)
		b.TextYAlignment = Enum.TextYAlignment.Bottom
		b.TextSize = 26
		b.Activated:Connect(function()
			Panels.close(s)
			s.play:Fire(mode)
		end)
	end
	Ui.text(
		modes,
		"Description",
		"Choose a duel or warm up against a practice opponent.",
		20,
		278,
		420,
		32,
		14
	)
	local help = window(s, "How to play", 500, 370)
	local steps = {
		{ "1", "Choose a hero", "Three offers each round. One free pick per match." },
		{ "2", "Set your direction", "Aim on the court, then lock it in." },
		{ "3", "Spin, paint, win", "Weapons paint. KO, or area then HP." },
	}
	for i, step in steps do
		local row = Ui.frame(help, "Step" .. i, 20, 71 + (i - 1) * 77, 460, 65, Color3.fromRGB(25, 46, 71))
		Ui.text(row, "Number", step[1], 5, 8, 48, 48, 30, true)
		local name = Ui.text(row, "Title", step[2], 65, 4, 382, 28, 19)
		name.TextXAlignment = Enum.TextXAlignment.Left
		local body = Ui.text(row, "Body", step[3], 65, 32, 382, 27, 14)
		body.TextXAlignment = Enum.TextXAlignment.Left
	end
	Ui.text(
		help,
		"Foot",
		"Brighter tiles are reinforced. Repaint them to take control.",
		22,
		313,
		456,
		38,
		14
	)
	local trade = window(s, "Trade", 460, 340)
	Art.image(trade, "TradeArt", "Trade", 183, 74, 94, 94)
	Ui.text(trade, "Title", "Your collection, shared", 25, 186, 410, 33, 24)
	Ui.text(
		trade,
		"Body",
		"Trading is not available yet.\nEvery current ball is free in Inventory.",
		30,
		233,
		400,
		57,
		17
	)
	local emotes = window(s, "Emotes", 440, 306)
	for i, name in { "Wave", "Cheer", "Dance", "Laugh" } do
		local b = Ui.button(
			emotes,
			name,
			name,
			19 + (i - 1) % 2 * 209,
			78 + math.floor((i - 1) / 2) * 99,
			193,
			81,
			Color3.fromRGB(38, 72, 105)
		)
		b.TextYAlignment = Enum.TextYAlignment.Bottom
		b.TextSize = 17
		Art.image(b, "Pose", "Emote", 77, 1, 39, 43)
		b.Activated:Connect(function()
			local character = Players.LocalPlayer.Character
			local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
			if humanoid then
				local ok, played = pcall(function()
					return humanoid:PlayEmote(string.lower(name))
				end)
				if not ok or not played then
					Panels.notify(s, "This avatar does not support that emote.")
				else
					Panels.close(s)
				end
			end
		end)
	end
	local invite = window(s, "Invite friends", 430, 320)
	Art.image(invite, "Envelope", "Invite", 169, 73, 92, 92)
	Ui.text(invite, "Body", "A friendly rivalry starts with a duel.", 25, 181, 380, 35, 19)
	local invitation = Ui.button(invite, "Invite", "Invite Friends", 97, 248, 236, 43, blue)
	invitation.Activated:Connect(function()
		local ok = pcall(function()
			SocialService:PromptGameInvite(Players.LocalPlayer)
		end)
		if not ok then
			Panels.notify(s, "Invites are available from the published game.")
		end
	end)
	local escapeConnection = UserInputService.InputBegan:Connect(function(input, processed)
		if not processed and input.KeyCode == Enum.KeyCode.Escape and s.active ~= "" then
			Panels.close(s)
		end
	end)
	layer.Destroying:Once(function()
		escapeConnection:Disconnect()
	end)
	for name, panel in s.windows do
		if name ~= "Inventory" and name ~= "Store" then
			Ui.actionTheme(panel)
			Ui.actionHeader(panel, 58)
			local heading = panel:FindFirstChild("Heading") :: TextLabel
			heading.ZIndex = 2
			heading.TextSize = if #name > 11 then 28 else 34
		end
	end
	ActionMenus.install(s.windows, function(name)
		Panels.open(s, name)
	end)
	for _, panel in s.windows do
		local close = panel:FindFirstChild("Close") :: TextButton
		local stroke = close:FindFirstChild("Edge", true) :: UIStroke
		stroke.Color = Ui.actionColors.text
		stroke.Thickness = 2
		local cross = close:FindFirstChild("Cross") :: TextLabel
		cross.FontFace = Ui.displayFont
		cross.TextColor3 = Ui.actionColors.text
	end
	Panels.select(s, "Astra")
	return s
end
function Panels.layout(s: State, viewport: Vector2, rootScale: number)
	if s.layoutSize == viewport then
		return
	end
	if s.openTween then
		s.openTween:Cancel()
		s.openTween = nil
	end
	s.layoutSize = viewport
	if next(s.base) == nil then
		for _, item in s.layer:GetDescendants() do
			if item:IsA("GuiObject") then
				s.base[item] = {
					size = item.Size,
					position = item.Position,
					textSize = if item.Name ~= "ButtonText"
							and (item:IsA("TextLabel") or item:IsA("TextButton"))
						then item.TextSize
						else nil,
				}
			end
		end
	else
		for item, base in s.base do
			item.Size = base.size
			item.Position = base.position
			if base.textSize and (item:IsA("TextLabel") or item:IsA("TextButton")) then
				-- Both engine classes expose TextSize; refine their shared property for the analyzer.
				local textObject = item :: TextLabel
				textObject.TextSize = base.textSize
			end
		end
	end
	local function box(item: GuiObject, x: number, y: number, w: number, h: number)
		item.Position = UDim2.fromOffset(x, y)
		item.Size = UDim2.fromOffset(w, h)
	end
	local function child(parent: Instance, name: string): GuiObject
		local item = parent:FindFirstChild(name)
		assert(item and item:IsA("GuiObject"), "Missing panel component: " .. name)
		return item
	end
	for _, scale in s.scales do
		local parent = scale.Parent :: Frame
		if parent.Name == "Inventory" or parent.Name == "Store" then
			continue
		end
		scale.Scale = math.min(
			1,
			(viewport.X - 32) / parent.Size.X.Offset,
			(viewport.Y - 32) / parent.Size.Y.Offset
		) / rootScale
		local minimum = math.ceil(44 / (rootScale * scale.Scale))
		local close = child(parent, "Close") :: TextButton
		box(
			close,
			parent.Size.X.Offset - math.max(46, minimum) - 8,
			6,
			math.max(46, minimum),
			math.max(46, minimum)
		)
		local cross = child(close, "Cross")
		cross.Position = UDim2.fromScale(0, 0)
		cross.Size = UDim2.fromScale(1, 1)
		do
			for _, b in parent:GetDescendants() do
				if
					b:IsA("TextButton")
					and b.Name ~= "Close"
					and b.Name ~= "ModalSurface"
					and b.Size.Y.Offset < minimum
				then
					local owner = b.Parent
					if owner and owner:IsA("GuiObject") then
						b.Size = UDim2.fromOffset(b.Size.X.Offset, minimum)
						b.Position = UDim2.fromOffset(
							b.Position.X.Offset,
							math.min(b.Position.Y.Offset, owner.Size.Y.Offset - minimum - 6)
						)
					end
				end
			end
		end
		-- Shrink the panel geometry only; body copy retains a readable physical floor.
		for _, label in parent:GetDescendants() do
			if label:IsA("TextLabel") and label.Name ~= "ButtonText" then
				label.TextSize = math.max(label.TextSize, math.ceil(13 / (rootScale * scale.Scale)))
			end
		end
	end
	ActionMenus.layout(s.windows, viewport, rootScale)
	-- Keep feedback above desktop modals and in the free centre of landscape headers.
	local toastWidth = math.min(420, viewport.X - 32)
	s.toast.Position = UDim2.fromOffset(
		(803 - toastWidth / rootScale) / 2,
		(602 - viewport.Y / rootScale) / 2 + 12 / rootScale
	)
	s.toast.Size = UDim2.fromOffset(toastWidth / rootScale, 48 / rootScale)
	s.toast.TextSize = 13 / rootScale
	-- ButtonText mirrors its button. Restoring a cached child font can race the
	-- button's deferred property signal when resizing back from a compact viewport.
	for _, item in s.layer:GetDescendants() do
		if item:IsA("TextButton") then
			local caption = item:FindFirstChild("ButtonText")
			if caption and caption:IsA("TextLabel") then
				caption.TextSize = item.TextSize
			end
		end
	end
end
return table.freeze(Panels)
