--!strict
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Shared = game:GetService("ReplicatedStorage").Shared
local Appearances = require(Shared.AppearanceCatalog)
local Types = require(Shared.Types)
local ViewTypes = require(Shared.ViewTypes)
local Art = require(script.Parent.BallArt)
local Layout = require(script.Parent.ReferenceLayout)
local Ui = require(script.Parent.ReferenceUi)
local Hud = {}
local purple = Color3.fromRGB(132, 123, 184)
local gold = Color3.fromRGB(255, 184, 0)
local function gui(name: string, order: number): ScreenGui
	local g = Instance.new("ScreenGui")
	g.Name = name
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.ScreenInsets = Enum.ScreenInsets.None
	g.DisplayOrder = order
	g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	g.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
	return g
end
local function avatar(parent: Instance, x: number, y: number, w: number, h: number): ViewportFrame
	local v = Instance.new("ViewportFrame")
	v.Name = "PlayerFigure"
	v.Position = UDim2.fromOffset(x, y)
	v.Size = UDim2.fromOffset(w, h)
	v.BackgroundTransparency = 1
	v.Ambient = Color3.fromRGB(150, 160, 180)
	v.LightColor = Color3.new(1, 1, 1)
	v.LightDirection = Vector3.new(-1, -1, -2)
	local world = Instance.new("WorldModel")
	world.Parent = v
	local c = Instance.new("Camera")
	c.FieldOfView = 30
	c.CFrame = CFrame.new(0, 0, 12)
	c.Parent = v
	v.CurrentCamera = c
	v.Parent = parent
	return v
end
local function loadAvatarAsync(viewport: ViewportFrame, userId: number)
	viewport:SetAttribute("UserId", userId)
	task.spawn(function()
		local ok, model = pcall(function(): Model
			local player = Players:GetPlayerByUserId(userId)
			local character = if player then player.Character else nil
			if character then
				local archivable = character.Archivable
				character.Archivable = true
				local clone = character:Clone()
				character.Archivable = archivable
				return clone
			end
			if userId > 0 then
				return Players:CreateHumanoidModelFromUserIdAsync(userId)
			end
			local d = Instance.new("HumanoidDescription")
			d.HeadColor = Color3.fromRGB(244, 204, 141)
			d.LeftArmColor = d.HeadColor
			d.RightArmColor = d.HeadColor
			d.TorsoColor = Color3.fromRGB(38, 90, 147)
			d.LeftLegColor = Color3.fromRGB(32, 37, 49)
			d.RightLegColor = d.LeftLegColor
			local result = Players:CreateHumanoidModelFromDescriptionAsync(d, Enum.HumanoidRigType.R6)
			d:Destroy()
			return result
		end)
		if not ok then
			warn("BVS avatar preview unavailable", userId)
			return
		end
		if not viewport.Parent or viewport:GetAttribute("UserId") ~= userId then
			model:Destroy()
			return
		end
		local world = viewport:FindFirstChildOfClass("WorldModel")
		if not world then
			model:Destroy()
			return
		end
		world:ClearAllChildren()
		local rootPart = model:FindFirstChild("HumanoidRootPart")
		if rootPart and rootPart:IsA("BasePart") then
			model.PrimaryPart = rootPart
		end
		for _, item in model:GetDescendants() do
			if item:IsA("BasePart") then
				if
					rootPart
					and rootPart:IsA("BasePart")
					and (item.Position - rootPart.Position).Magnitude > 18
				then
					item:Destroy()
					continue
				end
				item.Anchored = true
				item.CanCollide = false
			elseif item:IsA("Script") or item:IsA("LocalScript") then
				item:Destroy()
			end
		end
		model:PivotTo(CFrame.Angles(0, math.pi + 0.10, 0))
		local box, size = model:GetBoundingBox()
		model:PivotTo(CFrame.new(-box.Position) * model:GetPivot())
		model.Parent = world
		local camera = viewport.CurrentCamera
		if camera then
			local aspect = viewport.Size.X.Offset / viewport.Size.Y.Offset
			local extent = math.max(size.Y, size.X / aspect)
			camera.CFrame = CFrame.new(0, 0, math.max(11, extent / (2 * math.tan(math.rad(15))) * 1.06))
		end
	end)
end
local function card(parent: Instance, id: string, x: number, y: number, width: number): TextButton
	local entry = Appearances.entries[id]
	local b = Ui.button(parent, id, "", x, y, width, 212, Color3.fromRGB(22, 25, 38))
	b.BackgroundTransparency = 0.10
	local edge = b:FindFirstChild("Edge") :: UIStroke
	edge.Enabled = false
	for _, side in { 0, width - 1 } do
		Ui.frame(b, "CardDivider", side, 0, 1, 212, Color3.fromRGB(185, 186, 199))
	end
	Ui.text(b, "Title", entry.name, 3, 16, width - 6, 30, if #entry.name > 12 then 14 else 21)
	local square = Ui.frame(b, "PreviewBackground", (width - 76) / 2, 52, 76, 76, Color3.fromRGB(80, 84, 93))
	local line = Instance.new("UIStroke")
	line.Color = Color3.fromRGB(204, 207, 211)
	line.Thickness = 0.8
	line.Parent = square
	local preview = Art.viewport(square, "KitPreview", id)
	preview.Size = UDim2.fromOffset(108, 108)
	preview.Position = UDim2.fromOffset(-16, -16)
	if preview.CurrentCamera then
		preview.CurrentCamera.CFrame = if id == "Axe"
			then CFrame.new(0, 0.85, 10.5)
			else CFrame.new(0, 0, 7.2)
	end
	Ui.text(b, "Description", entry.description, 6, 136, width - 12, 65, 16)
	return b
end
function Hud.new()
	local g = gui("BallVsSpace", 20)
	local root, scale = Layout.root(g)
	local courtGui = gui("BVSReferenceCourt", 1)
	local courtRoot, courtScale = Layout.root(courtGui)
	local outer = Ui.frame(courtRoot, "Court", 145, 45, 512, 510, Color3.fromRGB(8, 19, 34))
	Ui.gradient(outer, Color3.fromRGB(14, 29, 47), Color3.fromRGB(6, 16, 30))
	-- Four mitred faces meet along the 45-degree corners seen in the reference.
	for depth = 0, 32 do
		local t = depth / 32
		Ui.frame(
			outer,
			"TopBevel",
			depth,
			depth,
			512 - depth * 2,
			1.1,
			Color3.fromRGB(8, 18, 35):Lerp(Color3.fromRGB(9, 22, 39), t)
		)
		Ui.frame(
			outer,
			"BottomBevel",
			depth,
			509 - depth,
			512 - depth * 2,
			1.1,
			Color3.fromRGB(16, 28, 44):Lerp(Color3.fromRGB(39, 55, 73), t)
		)
		Ui.frame(
			outer,
			"LeftBevel",
			depth,
			depth,
			1.1,
			510 - depth * 2,
			Color3.fromRGB(21, 36, 54):Lerp(Color3.fromRGB(34, 49, 67), t)
		)
		Ui.frame(
			outer,
			"RightBevel",
			511 - depth,
			depth,
			1.1,
			510 - depth * 2,
			Color3.fromRGB(11, 24, 41):Lerp(Color3.fromRGB(27, 43, 62), t)
		)
	end
	local surface = Ui.frame(courtRoot, "Playfield", 178, 78, 446, 446, Color3.new(1, 1, 1))
	Ui.gradient(surface, Color3.fromRGB(24, 44, 77), Color3.fromRGB(25, 48, 80))
	for i = 1, 4 do
		local horizontal = i <= 2
		local shadow = Ui.frame(
			surface,
			"InnerShadow",
			if i == 4 then 431 else 0,
			if i == 2 then 431 else 0,
			if horizontal then 446 else 15,
			if horizontal then 15 else 446,
			Color3.new()
		)
		shadow.BackgroundTransparency = 0.42
		local grad = Instance.new("UIGradient")
		grad.Transparency = NumberSequence.new(0, 1)
		grad.Rotation = if i == 1 then 90 elseif i == 2 then -90 elseif i == 3 then 0 else 180
		grad.Parent = shadow
	end
	local phase = Ui.text(root, "Phase", "", 164, 3, 480, 38, 24, true)
	local timer = Ui.text(root, "Clock", "", 351, 9, 100, 30, 24, true)
	local controls = Ui.frame(root, "Controls", 0, 0, 803, 602, Color3.new())
	controls.BackgroundTransparency = 1
	controls.ZIndex = 5
	local play = Ui.button(controls, "Left", "Play", 319, 545, 166, 36, Color3.fromRGB(112, 224, 0))
	local practice = Ui.button(controls, "Right", "Practice", 610, 207, 164, 34, purple)
	practice.TextSize = 16
	local primary = Ui.button(controls, "Primary", "Lock Aim", 334, 447, 136, 44, gold)
	local hint = Ui.text(root, "Hint", "", 205, 408, 392, 30, 14)
	local status = Ui.text(root, "Status", "", 200, 577, 405, 20, 11)
	status.Visible = false
	local help = Ui.text(root, "Help", "", 205, 550, 390, 25, 13)
	local points = Ui.text(root, "Points", "", 280, 557, 240, 22, 12, true)
	local scoreA = Ui.text(root, "ScoreA", "", 185, 526, 140, 25, 16, true)
	local scoreB = Ui.text(root, "ScoreB", "", 480, 526, 140, 25, 16, true)
	local barA = Ui.frame(root, "BarA", 178, 548, 0, 3, Color3.fromRGB(90, 215, 250))
	local barB = Ui.frame(root, "BarB", 624, 548, 0, 3, Color3.fromRGB(255, 120, 100))
	barB.AnchorPoint = Vector2.new(1, 0)
	local draftShade = Ui.frame(root, "DraftShade", -500, -500, 1803, 1602, Color3.new())
	draftShade.BackgroundTransparency = 0.5
	draftShade.ZIndex = 3
	local draft = Ui.frame(root, "Draft", 0, 0, 803, 602, Color3.new())
	draft.BackgroundTransparency = 1
	draft.ZIndex = 4
	local draftTitle = Ui.text(draft, "Title", "CHOOSE YOUR BALL", 180, 127, 444, 42, 23, true)
	local cards = {}
	for i, id in { "Cell", "Axe", "Poison" } do
		cards[i] = card(draft, id, 160 + (i - 1) * 175, 194, 132)
	end
	local allBalls = Ui.button(draft, "AllBalls", "All Balls", 335, 438, 132, 36, purple)
	allBalls.TextSize = 17
	Ui.text(draft, "Free", "Free", 346, 424, 50, 20, 14, true)
	local reroll = Ui.button(draft, "Reroll", "Reroll", 490, 438, 72, 36, purple)
	reroll.TextSize = 13
	local sides, sideLabels, figures, portraits, kitIcons, kitNames, hearts = {}, {}, {}, {}, {}, {}, {}
	for i = 1, 2 do
		local f = Ui.frame(root, "PlayerSide" .. i, if i == 1 then 0 else 663, 0, 140, 480, Color3.new())
		f.BackgroundTransparency = 1
		local name = Ui.text(f, "PlayerName", "", if i == 1 then 66 else 0, 90, 72, 23, 13, true)
		local portrait = Instance.new("ImageLabel")
		portrait.Name = "Portrait"
		portrait.Size = UDim2.fromOffset(42, 42)
		portrait.Position = UDim2.fromOffset(if i == 1 then 20 else 72, 91)
		portrait.BackgroundColor3 = Color3.fromRGB(35, 53, 75)
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = portrait
		portrait.Parent = f
		local figure = avatar(f, -8, 260, 156, 205)
		local group = {}
		for j = 1, 3 do
			group[j] = Ui.heart(f, 8 + (j - 1) * 32, 253, 25)
			Ui.heart(f, (if i == 1 then 71 else 1) + (j - 1) * 24, 115, 19)
		end
		local kitIcon = Art.viewport(f, "KitIcon", "Acid")
		kitIcon.Size = UDim2.fromOffset(66, 66)
		kitIcon.Position = UDim2.fromOffset(if i == 1 then 12 else 64, 151)
		local kitName = Ui.text(f, "KitName", "?", if i == 1 then 0 else 45, 137, 90, 20, 13)
		sides[i] = f
		sideLabels[i] = name
		figures[i] = figure
		portraits[i] = portrait
		kitIcons[i] = kitIcon
		kitNames[i] = kitName
		hearts[i] = group
	end
	local currency = Ui.frame(root, "Currency", 17, 481, 180, 100, Color3.new())
	currency.BackgroundTransparency = 1
	local coin = Ui.frame(currency, "Coin", 2, 0, 43, 43, Color3.fromRGB(255, 202, 0))
	local round = Instance.new("UICorner")
	round.CornerRadius = UDim.new(1, 0)
	round.Parent = coin
	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 3
	stroke.Color = Color3.fromRGB(255, 149, 0)
	stroke.Parent = coin
	local center = Ui.frame(coin, "CoinCenter", 7, 7, 29, 29, Color3.fromRGB(255, 218, 39))
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = center
	local balance = Ui.text(currency, "Coins", "0", 55, -2, 125, 47, 30, true)
	balance.TextXAlignment = Enum.TextXAlignment.Left
	balance.TextColor3 = gold
	Ui.gem(currency, 0, 51)
	local gemPlus = Ui.text(currency, "Plus", "+", -4, 61, 30, 35, 35)
	gemPlus.TextColor3 = Color3.fromRGB(151, 235, 255)
	local gems = Ui.text(currency, "Gems", "0", 55, 48, 125, 47, 30, true)
	gems.TextXAlignment = Enum.TextXAlignment.Left
	gems.TextColor3 = Color3.fromRGB(131, 222, 255)
	local lobby = Ui.frame(root, "Lobby", 0, 0, 803, 602, Color3.new())
	lobby.BackgroundTransparency = 1
	local store = Ui.button(lobby, "Store", "Store", 18, 201, 66, 70, Color3.fromRGB(37, 61, 87))
	store.TextSize = 13
	local inventory = Ui.button(lobby, "Inventory", "Inventory", 18, 286, 66, 70, Color3.fromRGB(37, 61, 87))
	inventory.TextSize = 11
	local shopIcon = Ui.frame(store, "Icon", 15, 4, 36, 41, Color3.new())
	shopIcon.BackgroundTransparency = 1
	local dome = Ui.frame(shopIcon, "Dome", 5, 0, 26, 26, Color3.new(1, 1, 1))
	local domeCorner = Instance.new("UICorner")
	domeCorner.CornerRadius = UDim.new(1, 0)
	domeCorner.Parent = dome
	local inset = Ui.frame(dome, "Glass", 3, 3, 20, 20, Color3.fromRGB(37, 61, 87))
	local ic = Instance.new("UICorner")
	ic.CornerRadius = UDim.new(1, 0)
	ic.Parent = inset
	for j = 1, 5 do
		local dot = Ui.frame(inset, "Ball", 3 + (j % 3) * 5, 5 + (j // 3) * 6, 4, 4, Color3.new(1, 1, 1))
		local dc = Instance.new("UICorner")
		dc.CornerRadius = UDim.new(1, 0)
		dc.Parent = dot
	end
	Ui.polygon(
		shopIcon,
		"Base",
		{ Vector2.new(7, 23), Vector2.new(29, 23), Vector2.new(34, 40), Vector2.new(2, 40) },
		Color3.new(1, 1, 1)
	)
	Ui.frame(shopIcon, "Slot", 14, 29, 9, 5, Color3.fromRGB(37, 61, 87))
	local cube = Ui.frame(inventory, "Icon", 10, 3, 46, 45, Color3.new())
	cube.BackgroundTransparency = 1
	Ui.polygon(
		cube,
		"Top",
		{ Vector2.new(0, 10), Vector2.new(22, 0), Vector2.new(44, 10), Vector2.new(22, 21) },
		Color3.new(1, 1, 1)
	)
	Ui.polygon(
		cube,
		"Left",
		{ Vector2.new(0, 14), Vector2.new(19, 24), Vector2.new(19, 44), Vector2.new(0, 34) },
		Color3.fromRGB(232, 243, 255)
	)
	Ui.polygon(
		cube,
		"Right",
		{ Vector2.new(24, 24), Vector2.new(44, 14), Vector2.new(44, 34), Vector2.new(24, 44) },
		Color3.new(1, 1, 1)
	)
	store.TextYAlignment = Enum.TextYAlignment.Bottom
	inventory.TextYAlignment = Enum.TextYAlignment.Bottom
	local emotes = Ui.button(lobby, "Emotes", "Emotes  R", 18, 373, 97, 29, Color3.fromRGB(37, 61, 87))
	emotes.TextSize = 11
	local quick = Ui.frame(lobby, "QuickJoin", 602, 176, 193, 68, Color3.fromRGB(18, 33, 61))
	quick.BackgroundTransparency = 0.25
	Ui.text(quick, "Title", "Quick Join", 0, -14, 193, 32, 18, true)
	local quests = Ui.frame(lobby, "Quests", 603, 10, 192, 155, Color3.fromRGB(19, 34, 54))
	quests.BackgroundTransparency = 0.22
	local questTab = Ui.frame(quests, "Tab", 0, 0, 192, 26, Color3.fromRGB(122, 174, 224))
	Ui.gradient(questTab, Color3.fromRGB(161, 198, 233), Color3.fromRGB(70, 122, 176))
	Ui.text(questTab, "Title", "Practice Quests", 6, 2, 180, 22, 12, true)
	local questEntries = {}
	for i, label in { "Choose a ball", "Lock your aim", "Win a round" } do
		local row = Ui.frame(quests, "Quest" .. i, 5, 30 + (i - 1) * 39, 182, 37, Color3.fromRGB(37, 56, 79))
		row.BackgroundTransparency = 0.25
		local title = Ui.text(row, "Title", label, 5, 0, 172, 19, 14)
		title.TextXAlignment = Enum.TextXAlignment.Left
		local progress = Ui.text(row, "Progress", "0/1", 5, 18, 45, 17, 12, true)
		progress.TextXAlignment = Enum.TextXAlignment.Left
		local rewardLabel = Ui.text(row, "Reward", "Free play", 70, 18, 108, 17, 10, true)
		rewardLabel.TextColor3 = gold
		questEntries[i] = progress
	end
	local reward = Ui.text(lobby, "Reward", "All Balls Free", 322, 510, 165, 26, 13, true)
	reward.BackgroundColor3 = Color3.fromRGB(18, 37, 62)
	reward.BackgroundTransparency = 0.3
	local settings = Ui.button(root, "Settings", "", 372, 12, 45, 45, Color3.fromRGB(18, 27, 35))
	Ui.gear(settings, 9, 9, 27, Color3.fromRGB(18, 27, 35))
	local settingsRound = Instance.new("UICorner")
	settingsRound.CornerRadius = UDim.new(1, 0)
	settingsRound.Parent = settings
	local settingsFill = settings:FindFirstChild("ButtonFill")
	if settingsFill then
		settingsRound:Clone().Parent = settingsFill
	end
	local settingsPanel = Ui.frame(root, "SettingsPanel", 245, 170, 313, 212, Color3.fromRGB(18, 27, 45))
	settingsPanel.Visible = false
	settingsPanel.ZIndex = 8
	settingsPanel.Active = true
	Ui.text(settingsPanel, "Title", "VIEW SETTINGS", 10, 10, 293, 35, 18, true)
	local territoryToggle =
		Ui.button(settingsPanel, "Territory", "Territory overlay: ON", 15, 65, 283, 44, purple)
	territoryToggle.TextSize = 13
	local motionToggle = Ui.button(settingsPanel, "Motion", "Reduced motion: OFF", 15, 126, 283, 44, purple)
	motionToggle.TextSize = 13
	local collection = Ui.frame(root, "Collection", 178, 123, 446, 318, Color3.fromRGB(26, 27, 43))
	collection.Visible = false
	collection.ZIndex = 8
	collection.Active = true
	local collectionEdge = Instance.new("UIStroke")
	collectionEdge.Color = Color3.fromRGB(99, 143, 203)
	collectionEdge.Thickness = 1
	collectionEdge.Parent = collection
	local collectionHeader = Ui.frame(collection, "Header", 1, 1, 444, 30, Color3.fromRGB(44, 47, 71))
	local collectionTitle = Ui.text(collectionHeader, "Title", "Select Any Ball", 0, 0, 444, 30, 21, true)
	local closeCollection = Ui.button(collection, "Close", "NO", 70, 281, 129, 31, Color3.fromRGB(235, 8, 0))
	local confirmCollection =
		Ui.button(collection, "Confirm", "YES", 248, 281, 129, 31, Color3.fromRGB(155, 158, 159))
	local collectionCards = {}
	for i, id in Appearances.ids do
		local entry = Appearances.entries[id]
		local x, y = 4 + ((i - 1) % 6) * 73, 31 + ((i - 1) // 6) * 73
		local slot = Ui.button(collection, id, "", x, y, 70, 69, Color3.fromRGB(37, 41, 60))
		local edge = slot:FindFirstChild("Edge") :: UIStroke
		edge.Color = Color3.fromRGB(106, 142, 201)
		edge.Thickness = 0.8
		local preview = Art.viewport(slot, "Preview", id)
		preview.Position = UDim2.fromOffset(2, 0)
		preview.Size = UDim2.fromOffset(66, 57)
		if preview.CurrentCamera then
			preview.CurrentCamera.CFrame = if id == "Axe"
				then CFrame.new(0, 0.7, 8.3)
				else CFrame.new(0, 0, 6.2)
		end
		local name = Ui.text(slot, "BallName", entry.name, 0, 56, 70, 13, if id == "Poison" then 6 else 9)
		name.BackgroundColor3 = Color3.fromRGB(32, 36, 58)
		name.BackgroundTransparency = 0.25
		collectionCards[i] = slot
	end
	local result = Ui.frame(root, "Results", 200, 108, 403, 395, Color3.fromRGB(33, 20, 185))
	result.Visible = false
	result.ZIndex = 4
	local border = Instance.new("UIStroke")
	border.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	border.Thickness = 10
	border.Color = Color3.fromRGB(16, 36, 57)
	border.Parent = result
	for i = 0, 11 do
		local stripe = Ui.frame(result, "Stripe", 0, i * 33, 403, 9, Color3.fromRGB(79, 63, 232))
		stripe.BackgroundTransparency = 0.55
	end
	local crown = Ui.frame(result, "Crown", 112, 23, 179, 110, Color3.new())
	crown.BackgroundTransparency = 1
	Ui.polygon(crown, "Gold", {
		Vector2.new(5, 25),
		Vector2.new(48, 52),
		Vector2.new(89, 0),
		Vector2.new(130, 52),
		Vector2.new(174, 25),
		Vector2.new(148, 90),
		Vector2.new(30, 90),
	}, gold)
	Ui.frame(crown, "Band", 31, 97, 116, 10, gold)
	Ui.polygon(
		crown,
		"Jewel",
		{ Vector2.new(89, 39), Vector2.new(103, 61), Vector2.new(89, 82), Vector2.new(75, 61) },
		Color3.fromRGB(40, 22, 190)
	)
	local winnerAvatar = avatar(result, 90, 145, 223, 185)
	local resultTitle = Ui.text(result, "ResultTitle", "VICTORY!", 20, 115, 363, 45, 30, true)
	local resultScore = Ui.text(result, "ResultScore", "", 10, 330, 383, 35, 17, true)
	local state = {
		gui = g,
		root = root,
		scale = scale,
		courtGui = courtGui,
		courtScale = courtScale,
		top = root,
		footer = controls,
		phase = phase,
		timer = timer,
		hint = hint,
		status = status,
		help = help,
		points = points,
		scoreA = scoreA,
		scoreB = scoreB,
		barA = barA,
		barB = barB,
		left = play,
		right = practice,
		primary = primary,
		cards = cards,
		draft = draft,
		draftShade = draftShade,
		draftTitle = draftTitle,
		allBalls = allBalls,
		reroll = reroll,
		sideFrames = sides,
		sideLabels = sideLabels,
		figures = figures,
		portraits = portraits,
		kitIcons = kitIcons,
		kitNames = kitNames,
		hearts = hearts,
		lobby = lobby,
		questEntries = questEntries,
		questsDone = { false, false, false },
		currency = currency,
		settings = settings,
		settingsPanel = settingsPanel,
		territoryToggle = territoryToggle,
		motionToggle = motionToggle,
		collection = collection,
		collectionCards = collectionCards,
		collectionTitle = collectionTitle,
		confirmCollection = confirmCollection,
		pendingAppearance = "Acid",
		store = store,
		inventory = inventory,
		emotes = emotes,
		result = result,
		resultTitle = resultTitle,
		resultScore = resultScore,
		winnerAvatar = winnerAvatar,
		showTerritory = true,
		selectedAppearance = "Acid",
		previousPhase = "",
	}
	collection:GetPropertyChangedSignal("Visible"):Connect(function()
		draft.Visible = state.previousPhase == "Draft" and not collection.Visible
		draftShade.Visible = state.previousPhase == "Draft" or collection.Visible
	end)
	settings.Activated:Connect(function()
		settingsPanel.Visible = not settingsPanel.Visible
	end)
	for _, slot in collectionCards do
		slot.Activated:Connect(function()
			state.pendingAppearance = slot.Name
			for _, other in collectionCards do
				local edge = other:FindFirstChild("Edge") :: UIStroke
				edge.Color = if other == slot then gold else Color3.fromRGB(106, 142, 201)
				edge.Thickness = if other == slot then 2 else 0.8
			end
		end)
	end
	allBalls.Activated:Connect(function()
		collection.Visible = true
	end)
	store.Activated:Connect(function()
		collection.Visible = true
	end)
	inventory.Activated:Connect(function()
		collection.Visible = true
	end)
	closeCollection.Activated:Connect(function()
		collection.Visible = false
	end)
	emotes.Activated:Connect(function()
		local character = Players.LocalPlayer.Character
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		if humanoid then
			pcall(function()
				humanoid:PlayEmote("wave")
			end)
		end
	end)
	return state
end
export type State = typeof(Hud.new())
function Hud.layout(h: State, phase: string)
	if h.previousPhase ~= phase then
		h.previousPhase = phase
		h.collection.Visible = false
		h.settingsPanel.Visible = false
	end
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	-- Fullscreen UI includes device insets that Camera.ViewportSize excludes.
	local viewport = h.gui.AbsoluteSize
	local scale = Layout.scale(viewport)
	local touchMinimum = if UserInputService.TouchEnabled then math.ceil(44 / scale) else 0
	h.scale.Scale = scale
	h.courtScale.Scale = scale
	local lobby = phase == "Lobby" or phase == "Queued"
	local portrait = viewport.X < viewport.Y
	h.courtGui.Enabled = not lobby
	h.lobby.Visible = lobby
	h.settings.Visible = lobby
	h.draft.Visible = phase == "Draft" and not h.collection.Visible
	h.draftShade.Visible = phase == "Draft" or h.collection.Visible
	h.result.Visible = phase == "RoundResult" or phase == "MatchResult"
	h.phase.Visible = phase == "Aim" or phase == "Countdown" or phase == "ReadyCheck"
	h.timer.Visible = phase == "Battle" or phase == "Overtime"
	h.left.Visible = lobby
	h.right.Visible = lobby
	h.primary.Visible = phase == "Aim" or phase == "MatchResult" or phase == "Queued"
	h.hint.Visible = false
	h.help.Visible = phase == "Queued"
	h.points.Visible = not lobby and phase ~= "Draft" and not h.result.Visible and h.showTerritory
	h.scoreA.Visible = h.points.Visible
	h.scoreB.Visible = h.points.Visible
	h.barA.Visible = h.points.Visible
	h.barB.Visible = h.points.Visible
	for _, f in h.sideFrames do
		f.Visible = not lobby and viewport.X >= viewport.Y
	end
	h.currency.Visible = lobby or phase == "Draft" or h.result.Visible
	h.primary.Position =
		UDim2.fromOffset(334, if phase == "MatchResult" then 517 elseif phase == "Queued" then 491 else 447)
	h.primary.Size = UDim2.fromOffset(136, math.max(44, touchMinimum))
	h.left.Size = UDim2.fromOffset(166, math.max(36, touchMinimum))
	h.right.Size = UDim2.fromOffset(164, math.max(34, touchMinimum))
	h.allBalls.Size = UDim2.fromOffset(132, math.max(36, touchMinimum))
	h.reroll.Size = UDim2.fromOffset(72, math.max(36, touchMinimum))
	h.left.Position = UDim2.fromOffset(if portrait then 232 else 319, 545)
	h.right.Position = UDim2.fromOffset(if portrait then 425 else 610, if portrait then 545 else 207)
	h.currency.Position = UDim2.fromOffset(if portrait then 130 else 17, 481)
	h.store.Position = UDim2.fromOffset(if portrait then 131 else 18, 201)
	h.inventory.Position = UDim2.fromOffset(if portrait then 131 else 18, 286)
	h.emotes.Position = UDim2.fromOffset(if portrait then 131 else 18, 373)
	local quests = h.lobby:FindFirstChild("Quests") :: Frame
	local quick = h.lobby:FindFirstChild("QuickJoin") :: Frame
	quests.Visible = not portrait
	quick.Visible = not portrait
end
function Hud.render(h: State, view: ViewTypes.State?, phase: string, board: Types.Board, reduced: boolean)
	Hud.layout(h, phase)
	h.motionToggle.Text = if reduced then "Reduced motion: ON" else "Reduced motion: OFF"
	h.territoryToggle.Text = if h.showTerritory then "Territory overlay: ON" else "Territory overlay: OFF"
	if not view then
		h.left.Text = if phase == "Queued" then "Searching…" else "Play"
		h.primary.Text = "Cancel"
		h.help.Text = if phase == "Queued" then "Waiting for another player…" else ""
		return
	end
	if phase == "Aim" then
		h.questsDone[1] = true
	elseif phase == "Battle" then
		h.questsDone[2] = true
	elseif phase == "RoundResult" or phase == "MatchResult" then
		local winner = view.seats[view.winner]
		if winner and winner.userId == Players.LocalPlayer.UserId then
			h.questsDone[3] = true
		end
	end
	for i, progress in h.questEntries do
		progress.Text = if h.questsDone[i] then "1/1" else "0/1"
	end
	h.points.Text = string.format("%g — %g", view.points2[1] / 2, view.points2[2] / 2)
	h.primary.Text = if phase == "MatchResult" then "Rematch" else "Lock Aim"
	for i, seat in view.seats do
		h.sideLabels[i].Text = seat.name
		if h.figures[i]:GetAttribute("UserId") ~= seat.userId then
			loadAvatarAsync(h.figures[i], seat.userId)
			if seat.userId > 0 then
				task.spawn(function()
					local ok, url = pcall(function()
						return Players:GetUserThumbnailAsync(
							seat.userId,
							Enum.ThumbnailType.HeadShot,
							Enum.ThumbnailSize.Size150x150
						)
					end)
					if ok and h.figures[i]:GetAttribute("UserId") == seat.userId then
						h.portraits[i].Image = url
					end
				end)
			end
		end
		local skin = seat.appearance or ""
		if h.kitIcons[i]:GetAttribute("Appearance") ~= skin then
			h.kitIcons[i]:SetAttribute("Appearance", skin)
			local world = h.kitIcons[i]:FindFirstChildOfClass("WorldModel")
			if world then
				world:ClearAllChildren()
				if skin ~= "" then
					Art.build(world, skin)
				end
			end
		end
		h.kitNames[i].Text = if skin ~= "" then Appearances.entries[skin].name else "?"
		for j, heart in h.hearts[i] do
			heart.Visible = j <= math.max(1, 4 - view.roundNumber)
		end
		if seat.userId == Players.LocalPlayer.UserId then
			if skin ~= "" then
				h.selectedAppearance = skin
			end
			if phase == "Aim" and seat.aimLocked then
				h.primary.Text = "Locked"
			end
		end
	end
	if h.result.Visible then
		local winner = view.seats[view.winner]
		h.resultTitle.Text = if not winner then "DRAW" else "VICTORY!"
		h.resultScore.Text =
			string.format("%.1f%%  —  %.1f%%", board.counts[1] / 10.24, board.counts[2] / 10.24)
		local userId = if winner then winner.userId else Players.LocalPlayer.UserId
		if h.winnerAvatar:GetAttribute("UserId") ~= userId then
			loadAvatarAsync(h.winnerAvatar, userId)
		end
	end
end
return table.freeze(Hud)
