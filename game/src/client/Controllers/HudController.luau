--!strict
local Players = game:GetService("Players")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Shared = game:GetService("ReplicatedStorage").Shared
local Appearances = require(Shared.AppearanceCatalog)
local Types = require(Shared.Types)
local ViewTypes = require(Shared.ViewTypes)
local Art = require(script.Parent.BallArt)
local Artwork = require(script.Parent.Artwork)
local Layout = require(script.Parent.ReferenceLayout)
local Panels = require(script.Parent.LobbyPanels)
local Ui = require(script.Parent.ReferenceUi)
local Hud = {}
local resultReasons = {
	disconnect_forfeit = "Disconnect forfeit",
	voluntary_forfeit = "Player left the match",
	inactivity_forfeit = "Inactive player forfeited",
	ready_timeout = "A player could not connect",
	cancelled_before_start = "Cancelled before play",
	both_teams_disconnected = "Both players disconnected",
	simulation_failure = "Simulation stopped safely",
	simulation_error = "Simulation stopped safely",
	simulation_debt = "Server could not keep up",
	service_timeout = "Match time limit reached",
}
local purple = Color3.fromRGB(132, 123, 184)
local gold = Color3.fromRGB(255, 184, 0)
local function gui(name: string, order: number): ScreenGui
	local g = Instance.new("ScreenGui")
	g.Name = name
	g.ResetOnSpawn = false
	g.IgnoreGuiInset = true
	g.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
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
	draft.AnchorPoint = Vector2.new(0.5, 0.5)
	local draftScale = Instance.new("UIScale")
	draftScale.Parent = draft
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
	reroll.TextYAlignment = Enum.TextYAlignment.Bottom
	reroll.Size = UDim2.fromOffset(72, 44)
	Artwork.image(reroll, "RerollIcon", "Reroll", 24, 1, 25, 25)
	local sides, sideLabels, figures, portraits, kitIcons, kitNames, matchPoints = {}, {}, {}, {}, {}, {}, {}
	for i = 1, 2 do
		local f = Ui.frame(root, "PlayerSide" .. i, if i == 1 then 0 else 663, 0, 140, 480, Color3.new())
		f.BackgroundTransparency = 1
		local name = Ui.text(f, "PlayerName", "", if i == 1 then 66 else 0, 90, 72, 23, 13, true)
		name.TextColor3 = if i == 1 then Color3.fromRGB(95, 222, 244) else Color3.fromRGB(255, 126, 118)
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
		local tally = Ui.text(f, "MatchPoints", "0 / 2 PTS", 0, 74, 140, 24, 12, true)
		tally.BackgroundColor3 = Ui.actionColors.ink
		tally.BackgroundTransparency = 0.15
		tally.TextColor3 = name.TextColor3
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
		matchPoints[i] = tally
	end
	local currency = Ui.frame(root, "Currency", 17, 481, 180, 100, Color3.new())
	currency.BackgroundTransparency = 1
	local coin = Ui.frame(currency, "Coin", 2, 0, 43, 43, Color3.fromRGB(255, 202, 0))
	coin.BackgroundTransparency = 1
	Artwork.image(coin, "CoinArt", "Coin", -3, -3, 49, 49)
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
	shopIcon.AnchorPoint = Vector2.new(0.5, 0)
	shopIcon.Position = UDim2.new(0.5, 0, 0, 4)
	shopIcon.BackgroundTransparency = 1
	Artwork.image(shopIcon, "StoreArt", "Store", 0, 0, 36, 41)
	local cube = Ui.frame(inventory, "Icon", 10, 3, 46, 45, Color3.new())
	cube.AnchorPoint = Vector2.new(0.5, 0)
	cube.Position = UDim2.new(0.5, 0, 0, 3)
	cube.BackgroundTransparency = 1
	Artwork.image(cube, "InventoryArt", "Inventory", 0, 0, 46, 45)
	store.TextYAlignment = Enum.TextYAlignment.Bottom
	inventory.TextYAlignment = Enum.TextYAlignment.Bottom
	local emotes = Ui.button(lobby, "Emotes", "Emotes", 18, 373, 97, 29, Color3.fromRGB(37, 61, 87))
	emotes.TextSize = 11
	Artwork.image(emotes, "Pose", "Emote", 3, 4, 18, 21)
	local emoteText = emotes:FindFirstChild("ButtonText") :: TextLabel
	emoteText.Position = UDim2.fromOffset(20, 0)
	emoteText.Size = UDim2.new(1, -20, 1, 0)
	practice.Name = "Practice"
	practice.Parent = lobby
	practice.ZIndex = 2
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
	local gear = Ui.gear(settings, 9, 9, 27, Color3.fromRGB(18, 27, 35))
	gear.Position = UDim2.fromScale(0.2, 0.2)
	gear.Size = UDim2.fromScale(0.6, 0.6)
	local gearArt = gear:FindFirstChild("Teeth") :: ImageLabel
	gearArt.Size = UDim2.fromScale(1, 1)
	local settingsRound = Instance.new("UICorner")
	settingsRound.CornerRadius = UDim.new(1, 0)
	settingsRound.Parent = settings
	local settingsFill = settings:FindFirstChild("ButtonFill")
	if settingsFill then
		settingsRound:Clone().Parent = settingsFill
	end
	local rewards = Ui.button(root, "Rewards", "", 320, 12, 45, 45, Color3.fromRGB(18, 27, 35))
	local gift = Artwork.image(rewards, "Gift", "Gift", 10, 9, 26, 29)
	gift.Position = UDim2.fromScale(0.21, 0.2)
	gift.Size = UDim2.fromScale(0.58, 0.64)
	settingsRound:Clone().Parent = rewards
	settingsRound:Clone().Parent = rewards:FindFirstChild("ButtonFill")
	local profile = Ui.button(root, "Profile", "", 268, 12, 45, 45, Color3.fromRGB(18, 27, 35))
	settingsRound:Clone().Parent = profile
	settingsRound:Clone().Parent = profile:FindFirstChild("ButtonFill")
	local head = Instance.new("ImageLabel")
	head.Name = "Portrait"
	head.Size = UDim2.fromScale(0.86, 0.86)
	head.Position = UDim2.fromScale(0.07, 0.07)
	head.BackgroundTransparency = 1
	head.Parent = profile
	settingsRound:Clone().Parent = head
	task.spawn(function()
		local ok, url = pcall(function()
			return Players:GetUserThumbnailAsync(
				Players.LocalPlayer.UserId,
				Enum.ThumbnailType.HeadShot,
				Enum.ThumbnailSize.Size150x150
			)
		end)
		if ok and head.Parent then
			head.Image = url
		end
	end)
	local social = Ui.button(lobby, "Trade", "Trade", 699, 12, 96, 26, Color3.fromRGB(56, 83, 109))
	social.TextSize = 12
	local handshake = Artwork.image(social, "Handshake", "Trade", 3, 3, 21, 20)
	handshake.AnchorPoint = Vector2.new(0, 0.5)
	handshake.Position = UDim2.new(0, 3, 0.5, 0)
	local questTitle = questTab:FindFirstChild("Title") :: TextLabel
	questTab.Size = UDim2.fromOffset(96, 26)
	questTitle.Size = UDim2.fromOffset(94, 22)
	questTitle.Position = UDim2.fromOffset(1, 2)
	questTitle.Text = "Quests"
	questTitle.TextSize = 12
	local invite = Ui.button(lobby, "Invite", "Invite", 731, 481, 61, 73, Color3.fromRGB(24, 37, 61))
	invite.TextYAlignment = Enum.TextYAlignment.Bottom
	invite.TextSize = 16
	Artwork.image(invite, "Envelope", "Invite", 8, 6, 45, 43)
	local helpButton = Ui.button(root, "HelpButton", "", 722, 521, 69, 69, Color3.fromRGB(32, 34, 39))
	Artwork.image(helpButton, "Chat", "Chat", 14, 14, 41, 41)
	local modeButton = Ui.button(lobby, "Mode", "1V1", 250, 545, 61, 36, Color3.fromRGB(29, 43, 65))
	modeButton.TextSize = 17
	local settingsPanel = Ui.frame(root, "SettingsPanel", 245, 170, 313, 212, Color3.fromRGB(18, 27, 45))
	settingsPanel.Visible = false
	settingsPanel.ZIndex = 8
	settingsPanel.Active = true
	local settingsScale = Instance.new("UIScale")
	settingsScale.Parent = settingsPanel
	settingsPanel.AnchorPoint = Vector2.new(0.5, 0.5)
	local settingsTitle = Ui.text(settingsPanel, "Title", "VIEW SETTINGS", 12, 12, 270, 35, 18, true)
	settingsTitle.TextXAlignment = Enum.TextXAlignment.Left
	local settingsClose = Ui.button(settingsPanel, "Close", "", 304, 6, 44, 44, Color3.fromRGB(239, 39, 63))
	Artwork.image(settingsClose, "Cross", "Close", 6, 6, 32, 32)
	settingsClose.ZIndex = 5
	settingsClose.Activated:Connect(function()
		settingsPanel.Visible = false
	end)
	local territoryToggle =
		Ui.button(settingsPanel, "Territory", "Territory overlay: ON", 15, 65, 283, 44, purple)
	territoryToggle.TextSize = 13
	local motionToggle = Ui.button(settingsPanel, "Motion", "Reduced motion: OFF", 15, 126, 283, 44, purple)
	motionToggle.TextSize = 13
	local collection = Ui.frame(root, "Collection", 178, 123, 446, 318, Color3.fromRGB(26, 27, 43))
	collection.Visible = false
	collection.ZIndex = 8
	collection.Active = true
	local collectionScale = Instance.new("UIScale")
	collectionScale.Parent = collection
	collection.AnchorPoint = Vector2.new(0.5, 0.5)
	local collectionEdge = Instance.new("UIStroke")
	collectionEdge.Color = Color3.fromRGB(99, 143, 203)
	collectionEdge.Thickness = 1
	collectionEdge.Parent = collection
	local collectionHeader = Ui.frame(collection, "Header", 1, 1, 444, 30, Color3.fromRGB(44, 47, 71))
	local collectionTitle = Ui.text(collectionHeader, "Title", "Select Any Ball", 0, 0, 444, 30, 21, true)
	local closeCollection =
		Ui.button(collection, "Close", "Back", 70, 281, 129, 31, Color3.fromRGB(235, 8, 0))
	local confirmCollection =
		Ui.button(collection, "Confirm", "Choose Ball", 248, 281, 129, 31, Color3.fromRGB(155, 158, 159))
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
	local crown = Ui.frame(result, "Crown", 112, 23, 179, 110, Color3.new())
	crown.BackgroundTransparency = 1
	local crownArt = Artwork.image(crown, "CrownArt", "Crown", 0, 0, 179, 110)
	crownArt.ScaleType = Enum.ScaleType.Stretch
	local winnerAvatar = avatar(result, 90, 145, 223, 185)
	result.AnchorPoint = Vector2.new(0.5, 0.5)
	local resultScale = Instance.new("UIScale")
	resultScale.Parent = result
	local resultContext = Ui.text(result, "ResultContext", "MATCH COMPLETE", 12, 12, 379, 20, 13)
	local resultMetric = Ui.text(result, "ResultMetric", "MATCH POINTS", 12, 300, 379, 20, 13)
	local resultNote = Ui.text(result, "ResultNote", "", 12, 372, 379, 18, 12)
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
		matchPoints = matchPoints,
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
		resultContext = resultContext,
		resultMetric = resultMetric,
		resultNote = resultNote,
		winnerAvatar = winnerAvatar,
		showTerritory = true,
		selectedAppearance = "Acid",
		previousPhase = "",
		layoutViewport = Vector2.zero,
		layoutMargin = 0,
		layoutPhase = "",
		layoutTouch = false,
		layoutTerritory = true,
		rewards = rewards,
		profile = profile,
		helpButton = helpButton,
		modeButton = modeButton,
		panels = Panels.new(root),
	}
	collection:GetPropertyChangedSignal("Visible"):Connect(function()
		draft.Visible = state.previousPhase == "Draft" and not collection.Visible
		draftShade.Visible = state.previousPhase == "Draft" or collection.Visible
	end)
	settings.Activated:Connect(function()
		Panels.close(state.panels)
		settingsPanel.Visible = not settingsPanel.Visible
	end)
	rewards.Activated:Connect(function()
		settingsPanel.Visible = false
		Panels.open(state.panels, "Rewards")
	end)
	profile.Activated:Connect(function()
		settingsPanel.Visible = false
		Panels.open(state.panels, "Inventory")
	end)
	social.Activated:Connect(function()
		Panels.open(state.panels, "Trade")
	end)
	invite.Activated:Connect(function()
		Panels.open(state.panels, "Invite friends")
	end)
	helpButton.Activated:Connect(function()
		Panels.open(state.panels, "How to play")
	end)
	modeButton.Activated:Connect(function()
		Panels.open(state.panels, "Play")
	end)
	for _, slot in collectionCards do
		slot.Activated:Connect(function()
			state.pendingAppearance = slot.Name
			for _, other in collectionCards do
				local edge = other:FindFirstChild("Edge") :: UIStroke
				edge.Color = if other == slot then Ui.actionColors.cyan else Ui.actionColors.line
				edge.Thickness = if other == slot then 2 else 0.8
			end
		end)
	end
	allBalls.Activated:Connect(function()
		collection.Visible = true
	end)
	store.Activated:Connect(function()
		Panels.open(state.panels, "Store")
	end)
	inventory.Activated:Connect(function()
		Panels.open(state.panels, "Inventory")
	end)
	closeCollection.Activated:Connect(function()
		collection.Visible = false
	end)
	emotes.Activated:Connect(function()
		Panels.open(state.panels, "Emotes")
	end)
	Ui.actionTheme(root, { Panels = true, Currency = true, PlayerSide1 = true, PlayerSide2 = true })
	Ui.actionHeader(settingsPanel, 56)
	Ui.actionHeader(collectionHeader, 40)
	local resultBand = Ui.actionHeader(result, 395)
	resultBand.BackgroundTransparency = 0.55
	for _, stripe in resultBand:GetChildren() do
		if stripe:IsA("Frame") then
			stripe.BackgroundTransparency = 0.95
		end
	end
	local draftBand = Ui.actionHeader(draft, 52)
	draftBand.Position = UDim2.fromOffset(145, 120)
	draftBand.Size = UDim2.fromOffset(512, 52)
	draftTitle.ZIndex = 2
	local theme = Ui.actionColors
	outer.BackgroundColor3 = theme.ink
	local courtGradient = outer:FindFirstChildOfClass("UIGradient") :: UIGradient
	courtGradient.Color = ColorSequence.new(theme.card, theme.ink)
	for _, bevel in outer:GetChildren() do
		if bevel:IsA("Frame") then
			local weight = math.clamp(bevel.Position.X.Offset / 32, 0, 1)
			bevel.BackgroundColor3 = theme.surface:Lerp(theme.line, weight * 0.25)
		end
	end
	local surfaceGradient = surface:FindFirstChildOfClass("UIGradient") :: UIGradient
	surfaceGradient.Color = ColorSequence.new(theme.card, theme.surface)
	return state
end
export type State = typeof(Hud.new())
function Hud.reroll(h: State, offset: number)
	for i, button in h.cards do
		local id = Appearances.ids[(offset + i - 1) % #Appearances.ids + 1]
		local entry = Appearances.entries[id]
		button.Name = id
		local title = button:FindFirstChild("Title") :: TextLabel
		title.Text = entry.name
		title.TextSize = if #entry.name > 12 then 16 else 21
		local description = button:FindFirstChild("Description") :: TextLabel
		description.Text = string.gsub(entry.description, "\n", " ")
		local square = button:FindFirstChild("PreviewBackground") :: Frame
		local preview = square:FindFirstChild("KitPreview") :: ViewportFrame
		Art.setSkin(preview, id)
		local world = preview:FindFirstChildOfClass("WorldModel")
		if world then
			world:ClearAllChildren()
			Art.build(world, id)
		end
		Art.animate(preview, 0, 0, true)
	end
end
function Hud.layout(h: State, phase: string)
	if h.previousPhase ~= phase then
		h.previousPhase = phase
		h.collection.Visible = false
		h.settingsPanel.Visible = false
		Panels.close(h.panels)
	end
	local camera = Workspace.CurrentCamera
	if not camera then
		return
	end
	-- All authored layers share the device-safe rectangle, including landscape notches.
	local viewport = h.gui.AbsoluteSize
	if
		h.layoutViewport == viewport
		and h.layoutPhase == phase
		and h.layoutTouch == UserInputService.TouchEnabled
		and h.layoutTerritory == h.showTerritory
	then
		return
	end
	-- Input hit testing must stay inside every ancestor, even when drawing is unclipped.
	-- Normalize the previous horizontal padding before laying out the next viewport.
	local fullWidthContainers = { Controls = true, Lobby = true, Panels = true }
	for _, child in h.root:GetChildren() do
		if child:IsA("GuiObject") then
			if fullWidthContainers[child.Name] then
				child.Size = UDim2.fromOffset(803, 602)
				for _, item in child:GetChildren() do
					if item:IsA("GuiObject") then
						item.Position -= UDim2.fromOffset(h.layoutMargin, 0)
					end
				end
			else
				child.Position -= UDim2.fromOffset(h.layoutMargin, 0)
			end
		end
	end
	h.layoutViewport = viewport
	h.layoutPhase = phase
	h.layoutTouch = UserInputService.TouchEnabled
	h.layoutTerritory = h.showTerritory
	local scale = Layout.scale(viewport)
	local touchMinimum = math.ceil(44 / scale)
	h.scale.Scale = scale
	h.courtScale.Scale = scale
	local lobby = phase == "Lobby" or phase == "Queued"
	GuiService.TouchControlsEnabled = lobby
	h.courtGui.Enabled = not lobby
	h.lobby.Visible = lobby
	h.settings.Visible = lobby
	h.rewards.Visible = lobby
	h.profile.Visible = lobby
	h.helpButton.Visible = not lobby and phase ~= "Draft"
	Panels.layout(h.panels, viewport, scale)
	-- Keep the draft picker and settings readable without changing the horizontal court.
	local function box(item: GuiObject, x: number, y: number, w: number, height: number)
		item.Position = UDim2.fromOffset(x, y)
		item.Size = UDim2.fromOffset(w, height)
	end
	local collectionWidth = math.min(700, viewport.X - 48)
	local collectionHeight = math.min(500, viewport.Y - 48)
	box(h.collection, 401.5, 301, collectionWidth, collectionHeight)
	local pickerScale = h.collection:FindFirstChildOfClass("UIScale") :: UIScale
	pickerScale.Scale = 1 / scale
	local header = h.collection:FindFirstChild("Header") :: Frame
	box(header, 0, 0, collectionWidth, 40)
	box(h.collectionTitle, 10, 0, collectionWidth - 20, 40)
	h.collectionTitle.TextSize = 20
	local slotWidth = (collectionWidth - 54) / 4
	local slotHeight = (collectionHeight - 112) / 3
	for i, slot in h.collectionCards do
		box(
			slot,
			12 + (i - 1) % 4 * (slotWidth + 10),
			46 + math.floor((i - 1) / 4) * (slotHeight + 6),
			slotWidth,
			slotHeight
		)
		local art = slot:FindFirstChild("Preview") :: ViewportFrame
		local size = math.min(88, slotHeight - 26)
		box(art, (slotWidth - size) / 2, 0, size, size)
		local name = slot:FindFirstChild("BallName") :: TextLabel
		box(name, 0, slotHeight - 28, slotWidth, 28)
		name.TextSize = 12
	end
	local cancel = h.collection:FindFirstChild("Close") :: TextButton
	box(cancel, 12, collectionHeight - 50, collectionWidth / 2 - 18, 44)
	box(h.confirmCollection, collectionWidth / 2 + 6, collectionHeight - 50, collectionWidth / 2 - 18, 44)
	box(h.settingsPanel, 401.5, 301, 360, 216)
	local settingsScale = h.settingsPanel:FindFirstChildOfClass("UIScale") :: UIScale
	settingsScale.Scale = 1 / scale
	box(h.settingsPanel:FindFirstChild("Title") :: TextLabel, 12, 12, 270, 35)
	box(h.territoryToggle, 18, 66, 324, 48)
	box(h.motionToggle, 18, 130, 324, 48)
	h.draft.Visible = phase == "Draft" and not h.collection.Visible
	h.draftShade.Visible = phase == "Draft" or h.collection.Visible
	h.result.Visible = phase == "RoundResult" or phase == "MatchResult"
	h.phase.Visible = phase == "Aim" or phase == "Countdown" or phase == "ReadyCheck"
	h.timer.Visible = phase == "Battle" or phase == "Overtime"
	h.left.Visible = phase == "Lobby" or h.result.Visible
	h.right.Visible = phase == "Lobby"
	h.primary.Visible = phase == "Aim" or phase == "MatchResult" or phase == "Queued"
	h.hint.Visible = phase == "Queued"
	h.hint.Position = UDim2.fromOffset(205, 160)
	h.hint.Size = UDim2.fromOffset(392, 40)
	h.hint.Text = "1 / 2 PLAYERS"
	h.hint.TextSize = 30
	h.hint.FontFace = Ui.displayFont
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
	local horizontalMargin = (viewport.X / scale - 803) / 2
	local leftEdge, rightEdge = -horizontalMargin, horizontalMargin
	local quests = h.lobby:FindFirstChild("Quests") :: Frame
	local trade = h.lobby:FindFirstChild("Trade") :: TextButton
	local invite = h.lobby:FindFirstChild("Invite") :: TextButton
	quests.Visible, trade.Visible, invite.Visible, h.modeButton.Visible = true, true, true, true
	-- Physical-size controls keep short landscape viewports usable.
	local function font(label: TextLabel | TextButton, pixels: number)
		(label :: TextLabel).TextSize = math.ceil(pixels / scale)
	end
	for _, b in { h.left, h.right, h.primary, h.modeButton } do
		font(b, 16)
	end
	h.primary.Size = UDim2.fromOffset(math.max(136, 116 / scale), math.max(44, touchMinimum))
	h.primary.Position = UDim2.fromOffset(401.5 - h.primary.Size.X.Offset / 2, h.primary.Position.Y.Offset)
	font(h.help, 13)
	h.help.Size = UDim2.fromOffset(390, math.max(25, 32 / scale))
	font(h.resultTitle, math.clamp(30 * scale, 22, 40))
	h.resultTitle.Size = UDim2.fromOffset(363, math.max(45, 28 / scale))
	font(h.resultScore, 17)
	h.resultScore.Size = UDim2.fromOffset(383, math.max(35, 24 / scale))
	for _, label in { h.scoreA, h.scoreB } do
		font(label, 14)
		label.Position = UDim2.fromOffset(label.Position.X.Offset, 602 - 40 / scale)
		label.Size = UDim2.fromOffset(140, 18 / scale)
	end
	font(h.points, 12)
	h.points.Position = UDim2.fromOffset(280, 602 - 18 / scale)
	h.points.Size = UDim2.fromOffset(240, 16 / scale)
	h.barA.Position = UDim2.fromOffset(178, 602 - 20 / scale)
	h.barB.Position = UDim2.fromOffset(624, 602 - 20 / scale)
	local sideWidth = math.clamp((viewport.X - 512 * scale) / 2 - 16, 104, 180)
	for i, frame in h.sideFrames do
		local ownScale = frame:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		ownScale.Parent = frame
		ownScale.Scale = 1 / scale
		box(
			frame,
			if i == 1 then leftEdge + 8 / scale else rightEdge + 803 - (sideWidth + 8) / scale,
			60 / scale,
			sideWidth,
			viewport.Y - 100
		)
		box(h.portraits[i], sideWidth / 2 - 21, 0, 42, 42)
		box(h.sideLabels[i], 0, 46, sideWidth, 24)
		h.sideLabels[i].TextSize = 12
		h.sideLabels[i].TextWrapped = false
		h.sideLabels[i].TextTruncate = Enum.TextTruncate.AtEnd
		box(h.kitNames[i], 0, 100, sideWidth, 32)
		h.kitNames[i].TextSize = 12
		box(h.kitIcons[i], sideWidth / 2 - 32, 134, 64, 64)
		box(h.figures[i], sideWidth / 2 - 60, 206, 120, 130)
		h.figures[i].Visible = viewport.Y >= 450
		local tallyWidth = math.min(116, sideWidth - 8)
		box(h.matchPoints[i], (sideWidth - tallyWidth) / 2, 74, tallyWidth, 24)
		h.matchPoints[i].TextSize = 12
	end
	local resultWidth = math.min(400, viewport.X - 2 * sideWidth - 48)
	local resultHeight = math.min(if viewport.Y < 450 then 236 else 420, viewport.Y - 108)
	local compactResult = resultHeight < 320
	box(h.result, 401.5, 301 - 10 / scale, resultWidth, resultHeight)
	local resultScale = h.result:FindFirstChildOfClass("UIScale") :: UIScale
	resultScale.Scale = 1 / scale
	box(h.result:FindFirstChild("ThemeHeader") :: Frame, 0, 0, resultWidth, resultHeight)
	box(h.resultContext, 12, 12, resultWidth - 24, 20)
	h.resultContext.TextSize = 13
	local crown = h.result:FindFirstChild("Crown") :: Frame
	box(crown, (resultWidth - 80) / 2, 36, 80, 50)
	box(crown:FindFirstChild("CrownArt") :: ImageLabel, 0, 0, 80, 50)
	box(h.resultTitle, 12, if compactResult then 88 else 94, resultWidth - 24, 34)
	h.resultTitle.TextSize = if compactResult then 24 else 30
	box(h.winnerAvatar, resultWidth / 2 - 78, 132, 156, math.max(60, resultHeight - 220))
	h.winnerAvatar.Visible = not compactResult
	box(h.resultMetric, 12, resultHeight - 82, resultWidth - 24, 20)
	h.resultMetric.TextSize = 13
	box(h.resultScore, 12, resultHeight - 60, resultWidth - 24, 32)
	h.resultScore.TextSize = if compactResult then 22 else 28
	box(h.resultNote, 12, resultHeight - 26, resultWidth - 24, 20)
	h.resultNote.TextSize = 12
	if phase == "MatchResult" then
		h.primary.Position = UDim2.fromOffset(401.5, 301 + (resultHeight / 2 + 2) / scale)
	end
	local statusWidth = math.min(360, viewport.X - 200)
	h.status.AnchorPoint = Vector2.new(0.5, 0)
	box(h.status, 401.5, 48 / scale, statusWidth / scale, 36 / scale)
	font(h.status, 13)
	h.status.BackgroundColor3 = Ui.actionColors.ink
	h.status.BackgroundTransparency = 0.12
	h.status.ZIndex = 10
	-- The compact quest card omits repeated reward copy, retaining progress.
	local questScale = quests:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
	questScale.Parent = quests
	questScale.Scale = 1 / scale
	quests.BackgroundTransparency = 0
	box(quests, rightEdge + 803 - 164 / scale, 62 / scale, 154, 126)
	box(quests:FindFirstChild("Tab") :: Frame, 0, 0, 154, 24)
	local questTitle = (quests:FindFirstChild("Tab") :: Frame):FindFirstChild("Title") :: TextLabel
	box(questTitle, 8, 0, 138, 24)
	questTitle.TextSize = 13
	for i = 1, 3 do
		local row = quests:FindFirstChild("Quest" .. i) :: Frame
		row.BackgroundTransparency = 0
		box(row, 4, 26 + (i - 1) * 32, 146, 30)
		local title = row:FindFirstChild("Title") :: TextLabel
		box(title, 6, 0, 103, 30)
		title.TextSize = 12
		local progress = row:FindFirstChild("Progress") :: TextLabel
		box(progress, 112, 0, 30, 30)
		progress.TextSize = 12
		(row:FindFirstChild("Reward") :: TextLabel).Visible = false
	end
	do
		local target = 45 / scale
		for i, button in { h.profile, h.rewards, h.settings } do
			box(button, leftEdge + (98 + (i - 1) * 52) / scale, 8 / scale, target, target)
		end
		h.currency.Position = UDim2.fromOffset(leftEdge + 12 / scale, 8 / scale)
		local currencyScale = h.currency:FindFirstChildOfClass("UIScale") or Instance.new("UIScale")
		currencyScale.Parent = h.currency
		currencyScale.Scale = 1 / scale
		box(h.currency, leftEdge + 12 / scale, 8 / scale, 78, 48)
		box(h.currency:FindFirstChild("Coin") :: Frame, 0, 0, 22, 22)
		local coinArt = (h.currency:FindFirstChild("Coin") :: Frame):FindFirstChild("CoinArt") :: ImageLabel
		coinArt.Position = UDim2.fromOffset(0, 0)
		coinArt.Size = UDim2.fromScale(1, 1)
		box(h.currency:FindFirstChild("Gem") :: Frame, 0, 25, 22, 22)
		local gemArt = (h.currency:FindFirstChild("Gem") :: Frame):FindFirstChild("Facets") :: ImageLabel
		gemArt.Size = UDim2.fromScale(1, 1)
		local plus = h.currency:FindFirstChild("Plus") :: TextLabel
		plus.Visible = false
		for i, key in { "Coins", "Gems" } do
			local label = h.currency:FindFirstChild(key) :: TextLabel
			box(label, 28, (i - 1) * 25, 44, 22)
			label.TextSize = 14
		end

		for i, button in { h.store, h.inventory } do
			box(button, leftEdge + 10 / scale, (80 + (i - 1) * 72) / scale, 84 / scale, 64 / scale)
			local icon = button:FindFirstChild("Icon") :: Frame
			icon.Size = UDim2.fromOffset(36 / scale, 38 / scale)
			icon.Position = UDim2.new(0.5, 0, 0, 4 / scale)
			local art = icon:FindFirstChildOfClass("ImageLabel") :: ImageLabel
			art.Size = UDim2.fromScale(1, 1)
		end
		box(h.emotes, leftEdge + 254 / scale, 8 / scale, 84 / scale, target)
		box(h.left, 401.5 - 56 / scale, 602 - 52 / scale, 112 / scale, target)
		box(h.right, 401.5 + 64 / scale, 602 - 52 / scale, 112 / scale, target)
		box(h.modeButton, 401.5 - 108 / scale, 602 - 52 / scale, target, target)
		box(trade, rightEdge + 803 - 94 / scale, 8 / scale, 84 / scale, target)
		box(invite, rightEdge + 803 - 166 / scale, 8 / scale, 64 / scale, target)
		box(h.helpButton, rightEdge + 803 - 54 / scale, 602 - 54 / scale, target, target)
		local chat = h.helpButton:FindFirstChild("Chat") :: ImageLabel
		chat.Position = UDim2.fromScale(0.16, 0.16)
		chat.Size = UDim2.fromScale(0.68, 0.68)
		local envelope = invite:FindFirstChild("Envelope") :: ImageLabel
		envelope.Position = UDim2.new(0.5, -12 / scale, 0, 3 / scale)
		envelope.Size = UDim2.fromOffset(24 / scale, 24 / scale)
		for _, definition in { { button = h.emotes, icon = "Pose" }, { button = trade, icon = "Handshake" } } do
			local button = definition.button
			local icon = button:FindFirstChild(definition.icon) :: ImageLabel
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.Position = UDim2.new(0, 6 / scale, 0.5, 0)
			icon.Size = UDim2.fromOffset(20 / scale, 20 / scale)
			local caption = button:FindFirstChild("ButtonText") :: TextLabel
			caption.Position = UDim2.fromOffset(28 / scale, 0)
			caption.Size = UDim2.new(1, -32 / scale, 1, 0)
		end
		for _, button in { h.store, h.inventory, h.emotes, trade, invite } do
			font(button, 12)
		end
	end
	if h.result.Visible then
		box(h.left, leftEdge + 8 / scale, 602 - 54 / scale, 90 / scale, 44 / scale)
	end
	local reward = h.lobby:FindFirstChild("Reward") :: TextLabel
	font(reward, 12)
	box(reward, 401.5 - 70 / scale, 602 - 78 / scale, 140 / scale, 22 / scale)
	-- Enforce physical target sizes on desktop windows too, not only touch emulation.
	for _, button in
		{ h.profile, h.rewards, h.settings, h.store, h.inventory, h.emotes, trade, invite, h.modeButton }
	do
		button.Size = UDim2.fromOffset(
			math.max(button.Size.X.Offset, touchMinimum),
			math.max(button.Size.Y.Offset, touchMinimum)
		)
	end
	local draftWidth, draftHeight = math.min(803, viewport.X - 24), math.min(602, viewport.Y - 24)
	box(h.draft, 401.5, 301, draftWidth, draftHeight)
	local draftScale = h.draft:FindFirstChildOfClass("UIScale") :: UIScale
	draftScale.Scale = 1 / scale
	local cardWidth = math.min(192, (draftWidth - 64) / 3)
	local cardHeight = math.min(244, draftHeight - 128)
	local previewSize = math.min(100, cardHeight - 104)
	local groupWidth = cardWidth * 3 + 32
	local startX = (draftWidth - groupWidth) / 2
	local startY = math.max(4, (draftHeight - cardHeight - 124) / 2)
	local band = h.draft:FindFirstChild("ThemeHeader") :: Frame
	box(band, startX, startY, groupWidth, 48)
	box(h.draftTitle, startX + 10, startY + 4, groupWidth - 20, 40)
	h.draftTitle.TextSize = if viewport.Y < 600 then 23 else 28
	for i, choice in h.cards do
		box(choice, startX + (i - 1) * (cardWidth + 16), startY + 60, cardWidth, cardHeight)
		box(choice:FindFirstChild("Title") :: TextLabel, 6, 10, cardWidth - 12, 32)
		box(
			choice:FindFirstChild("Description") :: TextLabel,
			10,
			50 + previewSize,
			cardWidth - 20,
			cardHeight - previewSize - 56
		)
		local description = choice:FindFirstChild("Description") :: TextLabel
		description.TextSize = 13
		description.Text = string.gsub(description.Text, "\n", " ")
		local art = choice:FindFirstChild("PreviewBackground") :: Frame
		box(art, (cardWidth - previewSize) / 2, 46, previewSize, previewSize)
		box(
			art:FindFirstChild("KitPreview") :: ViewportFrame,
			-previewSize * 0.12,
			-previewSize * 0.12,
			previewSize * 1.24,
			previewSize * 1.24
		)
		for _, line in choice:GetChildren() do
			if line:IsA("Frame") and line.Name == "CardDivider" then
				line.Visible = false
			end
		end
	end
	local actionsY = startY + cardHeight + 72
	box(h.allBalls, draftWidth / 2 - 144, actionsY, 160, 44)
	box(h.reroll, draftWidth / 2 + 36, actionsY, 108, 44)
	box(h.reroll:FindFirstChild("RerollIcon") :: ImageLabel, 42, 1, 25, 25)
	local free = h.draft:FindFirstChild("Free") :: TextLabel
	free.Visible = false
	-- Stretch interactive ancestors across the safe rectangle, retaining 803-unit content coordinates.
	h.root.Size = UDim2.fromOffset(viewport.X / scale, 602)
	h.layoutMargin = horizontalMargin
	for _, child in h.root:GetChildren() do
		if child:IsA("GuiObject") then
			if fullWidthContainers[child.Name] then
				child.Size = UDim2.fromOffset(viewport.X / scale, 602)
				for _, item in child:GetChildren() do
					if item:IsA("GuiObject") then
						item.Position += UDim2.fromOffset(horizontalMargin, 0)
					end
				end
			else
				child.Position += UDim2.fromOffset(horizontalMargin, 0)
			end
		end
	end
	h.primary.AnchorPoint = Vector2.new(0.5, 0)
	h.primary.Position = UDim2.new(0.5, 0, 0, h.primary.Position.Y.Offset)
end
function Hud.render(h: State, view: ViewTypes.State?, phase: string, board: Types.Board, reduced: boolean)
	Hud.layout(h, phase)
	if phase == "Draft" then
		-- Hidden previews may only finish cached image delivery when first shown.
		-- Reconcile the fallback while visible, even if IsLoaded emits no signal.
		if h.collection.Visible then
			for _, slot in h.collectionCards do
				Art.animate(slot:FindFirstChild("Preview") :: ViewportFrame, 0, 0, true)
			end
		else
			for _, slot in h.cards do
				local background = slot:FindFirstChild("PreviewBackground") :: Frame
				Art.animate(background:FindFirstChild("KitPreview") :: ViewportFrame, 0, 0, true)
			end
		end
	end
	h.panels.layer:SetAttribute("ReducedMotion", reduced)
	h.motionToggle.Text = if reduced then "Reduced motion: ON" else "Reduced motion: OFF"
	h.territoryToggle.Text = if h.showTerritory then "Territory overlay: ON" else "Territory overlay: OFF"
	if not view then
		h.left.Text = if phase == "Queued" then "Searching…" else "Play"
		h.primary.Text = "Leave"
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
	h.left.Text = "Replay"
	h.points.Text = string.format("%g — %g", view.points2[1] / 2, view.points2[2] / 2)
	h.primary.Text = if phase == "MatchResult"
		then (if view.rematchRequested then "Queued ✓" else "Rematch")
		else "Lock Aim"
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
						h.portraits[i].ImageRectOffset = Vector2.zero
						h.portraits[i].ImageRectSize = Vector2.zero
						h.portraits[i].Image = url
					end
				end)
			else
				Artwork.set(h.portraits[i], "Emote")
			end
		end
		local skin = seat.appearance or ""
		if h.kitIcons[i]:GetAttribute("Appearance") ~= skin then
			h.kitIcons[i]:SetAttribute("Appearance", skin)
			Art.setSkin(h.kitIcons[i], skin)
			local world = h.kitIcons[i]:FindFirstChildOfClass("WorldModel")
			if world then
				world:ClearAllChildren()
				if skin ~= "" then
					Art.build(world, skin)
				end
			end
		end
		h.kitNames[i].Text = if skin ~= "" then Appearances.entries[skin].name else "?"
		Art.animate(h.kitIcons[i], 0, 0, true)
		h.matchPoints[i].Text = string.format("%g / 2 PTS", view.points2[seat.team] / 2)
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
		local complete = phase == "MatchResult"
		local stopped = complete and view.winner == 0 and view.reason ~= "match_points"
		h.resultContext.Text = if stopped
			then "MATCH STOPPED"
			elseif complete then "MATCH COMPLETE"
			else "ROUND " .. view.roundNumber .. " / 3"
		h.resultTitle.Text = if stopped
			then "NO RESULT"
			elseif not winner then "DRAW"
			elseif winner.userId == Players.LocalPlayer.UserId then "VICTORY!"
			else "DEFEAT"
		local crown = h.result:FindFirstChild("Crown") :: Frame
		crown.Visible = not stopped
		h.resultMetric.Text = if stopped
			then "NO RESULT RECORDED"
			elseif complete then "MATCH POINTS"
			else "FINAL TERRITORY"
		h.resultScore.Text = if stopped
			then "—"
			elseif complete then string.format("%g — %g", view.points2[1] / 2, view.points2[2] / 2)
			else string.format("%.1f%% — %.1f%%", board.counts[1] / 10.24, board.counts[2] / 10.24)

		h.resultNote.Text = if resultReasons[view.reason]
			then resultReasons[view.reason]
			elseif complete then string.format(
				"Last round: %.1f%% — %.1f%%",
				board.counts[1] / 10.24,
				board.counts[2] / 10.24
			)
			else string.format("Match points: %g — %g", view.points2[1] / 2, view.points2[2] / 2)
		local userId = if winner then winner.userId else Players.LocalPlayer.UserId
		if h.winnerAvatar:GetAttribute("UserId") ~= userId then
			loadAvatarAsync(h.winnerAvatar, userId)
		end
	end
end
return table.freeze(Hud)
