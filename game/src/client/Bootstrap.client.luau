--!strict
local Players = game:GetService("Players")
local ProximityPromptService = game:GetService("ProximityPromptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
Players.LocalPlayer:WaitForChild("PlayerGui").ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor
local Shared = ReplicatedStorage:WaitForChild("Shared", 15)
assert(Shared, "Missing shared modules")
local Appearances = require(Shared.AppearanceCatalog)
local Math = require(Shared.TerritoryMath)
local Config = require(Shared.Config)
local Protocol = require(Shared.Protocol)
local Types = require(Shared.Types)
local ViewTypes = require(Shared.ViewTypes)
local Aim = require(script.Parent.Controllers.AimController)
local Artwork = require(script.Parent.Controllers.Artwork)
local Balls = require(script.Parent.Controllers.BallRenderer)
local Camera = require(script.Parent.Controllers.CameraController)
local Controller = require(script.Parent.Controllers.MatchController)
local Hud = require(script.Parent.Controllers.HudController)
local Panels = require(script.Parent.Controllers.LobbyPanels)
local Territory = require(script.Parent.Controllers.TerritoryRenderer)
local remotes = ReplicatedStorage:WaitForChild("Remotes", 15)
assert(remotes, "Missing game remotes")
local command = remotes:WaitForChild("ClientCommand", 10) :: RemoteEvent
local stateRemote = remotes:WaitForChild("MatchState", 10) :: RemoteEvent
local territoryRemote = remotes:WaitForChild("TerritoryUpdate", 10) :: RemoteEvent
local motion = remotes:WaitForChild("MotionSnapshot", 10) :: UnreliableRemoteEvent
local snapshotRequest = remotes:WaitForChild("SnapshotRequest", 10) :: RemoteEvent
local ack = remotes:WaitForChild("CommandAck", 10) :: RemoteEvent
local hud = Hud.new()
task.spawn(Artwork.preload)
local floor = Territory.new()
local balls = Balls.new()
local controller = Controller.new()
local view: ViewTypes.State? = nil
local phase = "Lobby"
local id = 0
local angle = 0
local dragging = false
local activePointer: InputObject? = nil
local pendingRematch: number? = nil
local lastClockPhase = ""
local lastClockSecond = -1
local pendingSelection: { id: number, matchId: string, roundId: number, generation: number }? = nil
local lastAim = 0
local lastSnapshot = 0
local reduced = false
local readySent = false
local lastStateAt = os.clock()
local replayAt: number? = nil
local replayIndex = 0
type Frame = { board: Types.Board, positions: { Protocol.Motion }, tick: number }
local history: { Frame } = {}
type Pending = { board: Types.Board, tick: number, due: number }
local pending: { Pending } = {}
local decodeBoard = controller.board
local function send(kind: string, kit: string?, direction: number?, appearance: string?): number
	id += 1
	local v = view
	command:FireServer({
		id = id,
		kind = kind,
		matchId = if v then v.id else "",
		roundId = if v then v.roundId else 0,
		generation = if v then v.generation else 0,
		kitId = kit,
		appearance = appearance,
		angle = direction,
		wildcard = if v and kind == "Select" and kit then table.find(v.offer, kit) == nil else nil,
	})
	return id
end
local function score(board: Types.Board)
	hud.scoreA.Text = string.format("◇ %.1f%%", 100 * board.counts[1] / 1024)
	hud.scoreB.Text = string.format("%.1f%% ○", 100 * board.counts[2] / 1024)
	hud.barA.Size = UDim2.fromOffset(board.counts[1] / 1024 * 446, 3)
	hud.barB.Size = UDim2.fromOffset(board.counts[2] / 1024 * 446, 3)
end
local function ownSeat(): ViewTypes.Seat?
	if view then
		for _, s in view.seats do
			if s.userId == Players.LocalPlayer.UserId then
				return s
			end
		end
	end
	return nil
end
local function renderUi()
	Hud.render(hud, view, phase, controller.board, reduced)
	floor.gui.Enabled = hud.showTerritory and view ~= nil
	hud.gui:SetAttribute("Phase", phase)
	hud.gui:SetAttribute("SelectedAppearance", hud.selectedAppearance)
	hud.gui:SetAttribute("AimAngle", angle)
	hud.gui:SetAttribute("MatchId", if view then view.id else nil)
	hud.gui:SetAttribute("RoundId", if view then view.roundId else nil)
	if phase == "RoundResult" or phase == "MatchResult" then
		hud.left.Visible = #history > 1 and replayAt == nil
		hud.result.Visible = replayAt == nil
		hud.primary.Visible = phase == "MatchResult" and replayAt == nil
	end
end
local function chooseAppearance(appearance: string)
	if pendingSelection then
		return
	end
	local entry = Appearances.entries[appearance]
	if not entry then
		return
	end
	if view and phase == "Draft" and view.wildcardUsed and not table.find(view.offer, entry.kit) then
		Panels.notify(hud.panels, "Free pick used. Choose one of the three offered heroes.")
		return
	end
	hud.selectedAppearance = appearance
	hud.collection.Visible = false
	if phase == "Lobby" then
		local index = table.find(Appearances.ids, appearance)
		if index then
			-- Put the equipped choice first; selection is still explicit each round.
			Hud.reroll(hud, index - 1)
		end
	end
	if phase == "Draft" and view then
		pendingSelection = {
			id = send("Select", entry.kit, nil, appearance),
			matchId = view.id,
			roundId = view.roundId,
			generation = view.generation,
		}
	end
end
hud.panels.equip.Event:Connect(chooseAppearance)
hud.panels.play.Event:Connect(function(mode: string)
	if phase == "Lobby" then
		send(if mode == "Practice" then "Practice" else "Queue")
	end
end)
ProximityPromptService.PromptTriggered:Connect(function(prompt: ProximityPrompt)
	if phase ~= "Lobby" then
		return
	end
	local action = prompt:GetAttribute("BVSAction")
	if action == "Practice" then
		send("Practice")
	elseif action == "Store" or action == "Inventory" or action == "Play" then
		Panels.open(hud.panels, action)
	end
end)
for _, card in hud.cards do
	card.Activated:Connect(function()
		chooseAppearance(card.Name)
	end)
end
hud.confirmCollection.Activated:Connect(function()
	chooseAppearance(hud.pendingAppearance)
end)
hud.territoryToggle.Activated:Connect(function()
	Panels.notify(hud.panels, "Territory stays visible so you can read the score.")
end)
hud.motionToggle.Activated:Connect(function()
	reduced = not reduced
	renderUi()
end)
hud.left.Activated:Connect(function()
	if phase == "Lobby" then
		Panels.close(hud.panels)
		send("Queue")
	elseif (phase == "RoundResult" or phase == "MatchResult") and #history > 1 then
		replayAt = os.clock()
		replayIndex = 0
		renderUi()
	end
end)
hud.right.Activated:Connect(function()
	if phase == "Lobby" then
		Panels.close(hud.panels)
		send("Practice")
	end
end)
hud.primary.Activated:Connect(function()
	if phase == "Queued" then
		send("Cancel")
	elseif phase == "Aim" then
		send("AimLock", nil, angle)
	elseif phase == "MatchResult" and view and not view.rematchRequested and not pendingRematch then
		pendingRematch = send("Rematch")
		hud.primary.Text = "Requesting…"
	end
end)
stateRemote.OnClientEvent:Connect(function(raw: unknown)
	if type(raw) ~= "table" then
		return
	end
	local state = raw :: ViewTypes.State
	local previousPhase = phase
	lastStateAt = os.clock()
	if state.phase == "Lobby" or state.phase == "Queued" then
		view = nil
		phase = state.phase
		pendingSelection = nil
		pendingRematch = nil
		dragging = false
		activePointer = nil
		replayAt = nil
		hud.status.Visible = false
		renderUi()
		return
	end
	if not view or view.id ~= state.id or view.roundId ~= state.roundId then
		controller = Controller.new()
		pendingRematch = nil
		decodeBoard = controller.board
		table.clear(pending)
		table.clear(history)
		replayAt = nil
		angle = state.localAngle
		Territory.apply(floor, controller.board)
		score(controller.board)
	end
	view = state
	phase = state.phase
	if phase ~= "Draft" then
		pendingSelection = nil
	end
	if phase ~= "Aim" then
		dragging = false
		activePointer = nil
	end
	local seat = ownSeat()
	if phase ~= "Aim" or previousPhase ~= "Aim" or (seat and seat.aimLocked) then
		angle = state.localAngle
	end
	renderUi()
end)
territoryRemote.OnClientEvent:Connect(function(matchId: string, roundId: number, payload: buffer)
	local v = view
	if not v or v.id ~= matchId or v.roundId ~= roundId or typeof(payload) ~= "buffer" then
		return
	end
	local board, tick = Protocol.decodeTerritory(payload, decodeBoard)
	if not board then
		if os.clock() - lastSnapshot >= 1 then
			lastSnapshot = os.clock()
			snapshotRequest:FireServer()
		end
		return
	end
	decodeBoard = board
	table.insert(pending, { board = board, tick = tick, due = os.clock() + 0.1 })
	if #pending > 30 then
		table.remove(pending, 1)
	end
end)
motion.OnClientEvent:Connect(function(matchId: string, roundId: number, payload: buffer)
	local v = view
	if not v or v.id ~= matchId or v.roundId ~= roundId or typeof(payload) ~= "buffer" then
		return
	end
	Controller.receive(controller, payload)
end)
ack.OnClientEvent:Connect(function(commandId: number, accepted: boolean, reason: string)
	if pendingRematch == commandId then
		pendingRematch = nil
		if accepted and view and phase == "MatchResult" then
			view.rematchRequested = true
		elseif not accepted then
			Panels.notify(hud.panels, "Rematch was not queued. Please try again.")
		end
		renderUi()
	end
	local selection = pendingSelection
	if selection and selection.id == commandId then
		if accepted then
			task.delay(0.22, function()
				local v = view
				if
					pendingSelection == selection
					and v
					and phase == "Draft"
					and v.id == selection.matchId
					and v.roundId == selection.roundId
					and v.generation == selection.generation
				then
					send("Commit")
				end
			end)
		else
			pendingSelection = nil
		end
	end
	if not accepted and reason ~= "duplicate" and reason ~= "rate" then
		Panels.notify(hud.panels, "Action arrived too late. Showing the server's choice.")
		snapshotRequest:FireServer()
	end
end)
local function updateAim(position: Vector2)
	local s = ownSeat()
	local camera = Workspace.CurrentCamera
	if phase ~= "Aim" or not s or s.aimLocked or not camera then
		return
	end
	local nextAngle = Aim.angle(hud.gui.AbsoluteSize, position - hud.gui.AbsolutePosition, s.x, s.z)
	if nextAngle then
		angle = math.floor(nextAngle + 0.5) % 360
		if os.clock() - lastAim >= 0.11 then
			lastAim = os.clock()
			send("Aim", nil, angle)
		end
	end
end
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then
		return
	end
	if input.KeyCode == Enum.KeyCode.R and phase == "Lobby" then
		Panels.open(hud.panels, "Emotes")
		return
	end
	if
		phase == "Aim"
		and not dragging
		and hud.panels.active == ""
		and (
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		)
	then
		dragging = true
		activePointer = input
		updateAim(Vector2.new(input.Position.X, input.Position.Y))
	end
end)
UserInputService.InputChanged:Connect(function(input: InputObject, processed: boolean)
	if
		dragging
		and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or (input.UserInputType == Enum.UserInputType.Touch and input == activePointer)
		)
	then
		updateAim(Vector2.new(input.Position.X, input.Position.Y))
	end
	if
		not processed
		and input.KeyCode == Enum.KeyCode.Thumbstick2
		and phase == "Aim"
		and input.Position.Magnitude > 0.2
	then
		local stick = input.Position
		angle = math.deg(math.atan2(-(stick.Y or 0), stick.X or 0)) % 360
		if os.clock() - lastAim >= 0.11 then
			lastAim = os.clock()
			send("Aim", nil, angle)
			renderUi()
		end
	end
end)
UserInputService.InputEnded:Connect(function(input)
	if input == activePointer then
		updateAim(Vector2.new(input.Position.X, input.Position.Y))
		dragging = false
		activePointer = nil
		local v = view
		task.delay(0.12, function()
			local current = view
			local seat = ownSeat()
			if
				v
				and current
				and current.id == v.id
				and current.roundId == v.roundId
				and current.generation == v.generation
				and phase == "Aim"
				and not dragging
				and seat
				and not seat.aimLocked
			then
				lastAim = os.clock()
				send("Aim", nil, angle)
			end
		end)
	end
end)
RunService:BindToRenderStep("BVSCamera", Enum.RenderPriority.Camera.Value + 1, function()
	local camera = Workspace.CurrentCamera
	if camera then
		Camera.fit(camera, phase)
		floor.scale.Scale = hud.scale.Scale
	end
end)
RunService.RenderStepped:Connect(function()
	local now = os.clock()
	if not readySent then
		readySent = true
		send("Ready")
	end
	local positions, poseTick = Controller.positions(controller, now)
	local boardUpdated = false
	while #pending > 0 and pending[1].due <= now do
		local update = table.remove(pending, 1)
		assert(update, "Pending territory queue unexpectedly empty")
		controller.board = update.board
		Territory.apply(floor, update.board)
		score(update.board)
		if view then
			view.tick = update.tick
		end
		if phase == "Battle" or phase == "Overtime" then
			table.insert(history, {
				board = update.board,
				positions = positions,
				tick = update.tick,
			})
			if #history > 20 then
				table.remove(history, 1)
			end
		end
		if RunService:IsStudio() then
			hud.gui:SetAttribute("BoardHash", Math.hash(update.board.q))
			hud.gui:SetAttribute("BoardVersion", update.board.version)
			hud.gui:SetAttribute("Tick", update.tick)
		end
		boardUpdated = true
	end
	-- Paint and scores update at 10 Hz; unchanged controls do not need rebuilding.
	if boardUpdated and phase ~= "Battle" and phase ~= "Overtime" then
		renderUi()
	end
	if view and view.phase ~= "Battle" and view.phase ~= "Overtime" and #controller.samples > 0 then
		positions = controller.samples[#controller.samples].balls
		poseTick = controller.samples[#controller.samples].tick
	end
	local renderedView = view
	if replayAt then
		local index = math.floor((now - replayAt) * 10) + 1
		if index > #history then
			replayAt = nil
			Territory.apply(floor, controller.board)
			score(controller.board)
			renderUi()
		else
			local frame = history[index]
			local nextFrame = history[math.min(index + 1, #history)]
			local alpha = ((now - replayAt) * 10) % 1
			positions = Controller.interpolate(frame.positions, nextFrame.positions, alpha)
			poseTick = frame.tick + (nextFrame.tick - frame.tick) * alpha
			if view then
				local replayView = table.clone(view)
				replayView.phase = "Battle"
				replayView.tick = frame.tick
				replayView.seats = {}
				for i, s in view.seats do
					local seat = table.clone(s)
					local p = positions[i]
					if p then
						seat.weapon = p.weapon
					end
					table.insert(replayView.seats, seat)
				end
				renderedView = replayView
			end
			if replayIndex ~= index then
				replayIndex = index
				Territory.apply(floor, frame.board)
				score(frame.board)
				for i, p in positions do
					local hp = p.weapon.hp
					hud.hpLabels[i].Text = if hp > 0 then string.format("%d / 100 HP", hp) else "KNOCKED OUT"
					hud.hpFills[i].Size = UDim2.fromScale(hp / 100, 1)
				end
			end
			hud.status.Text = "REPLAY · last 2 seconds · result locked"
		end
	end
	Balls.render(balls, positions, renderedView, reduced, poseTick)
	local v = view
	if v then
		if phase == "Aim" or phase == "Countdown" then
			for i, s in v.seats do
				if s.angle ~= nil then
					Aim.draw(
						balls.balls[i].aim,
						s.x,
						s.z,
						if s.userId == Players.LocalPlayer.UserId then angle else s.angle
					)
				end
			end
		end
		local seconds = if phase == "Battle"
			then (Config.BattleTicks - v.tick) / 60
			elseif phase == "Overtime" then (2700 - v.tick) / 60
			else v.deadline - Workspace:GetServerTimeNow()
		local secondsLeft = math.max(0, math.ceil(seconds))
		if lastClockPhase ~= phase or lastClockSecond ~= secondsLeft then
			lastClockPhase, lastClockSecond = phase, secondsLeft
			hud.draftTitle.Text = "CHOOSE YOUR HERO · " .. secondsLeft
			hud.collectionTitle.Text = if phase == "Draft"
				then "30 HEROES · " .. secondsLeft
				else "30 HEROES"
			hud.phase.Text = if phase == "Aim"
				then "ADJUST YOUR AIM - " .. secondsLeft
				elseif phase == "Countdown" then "GET READY - " .. secondsLeft
				else "CONNECTING…"
			hud.timer.Text = string.format("%02d:%02d", secondsLeft // 60, secondsLeft % 60)
		end
		local delayed = (phase == "Battle" or phase == "Overtime") and now - controller.lastReceived > 0.75
		hud.status.Visible = delayed or replayAt ~= nil
		if delayed then
			hud.status.Text = "Connection delayed · waiting for server"
		end
	elseif now - lastStateAt > 4 and now - lastSnapshot > 1 then
		lastSnapshot = now
		snapshotRequest:FireServer()
	end
end)
hud.gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
	Hud.layout(hud, phase)
end)
UserInputService:GetPropertyChangedSignal("TouchEnabled"):Connect(function()
	Hud.layout(hud, phase)
end)
renderUi()
print("BVS CLIENT READY")
