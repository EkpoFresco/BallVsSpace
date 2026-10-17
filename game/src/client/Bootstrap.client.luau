--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Shared = ReplicatedStorage:WaitForChild("Shared", 15)
assert(Shared, "Missing shared modules")
local Appearances = require(Shared.AppearanceCatalog)
local Math = require(Shared.TerritoryMath)
local Protocol = require(Shared.Protocol)
local Types = require(Shared.Types)
local ViewTypes = require(Shared.ViewTypes)
local Aim = require(script.Parent.Controllers.AimController)
local Balls = require(script.Parent.Controllers.BallRenderer)
local Camera = require(script.Parent.Controllers.CameraController)
local Controller = require(script.Parent.Controllers.MatchController)
local Hud = require(script.Parent.Controllers.HudController)
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
local floor = Territory.new()
local balls = Balls.new()
local controller = Controller.new()
local view: ViewTypes.State? = nil
local phase = "Lobby"
local id = 0
local angle = 0
local dragging = false
local lastAim = 0
local lastSnapshot = 0
local reduced = false
local readySent = false
local lastStateAt = os.clock()
local replayAt: number? = nil
type Frame = { board: Types.Board, positions: { Protocol.Motion }, tick: number }
local history: { Frame } = {}
type Pending = { board: Types.Board, tick: number, due: number }
local pending: { Pending } = {}
local decodeBoard = controller.board
local function send(kind: string, kit: string?, direction: number?, appearance: string?)
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
	})
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
end
local function chooseAppearance(appearance: string)
	local entry = Appearances.entries[appearance]
	if not entry then
		return
	end
	hud.selectedAppearance = appearance
	hud.collection.Visible = false
	if phase == "Draft" and view then
		local generation = view.generation
		send("Select", entry.kit, nil, appearance)
		task.delay(0.28, function()
			if view and phase == "Draft" and view.generation == generation then
				send("Commit")
			end
		end)
	end
end
for _, card in hud.cards do
	card.Activated:Connect(function()
		chooseAppearance(card.Name)
	end)
end
hud.confirmCollection.Activated:Connect(function()
	chooseAppearance(hud.pendingAppearance)
end)
hud.reroll.Activated:Connect(function()
	for i, card in hud.cards do
		card.Position = UDim2.fromOffset(160 + ((i + math.floor(os.clock())) % 3) * 175, 194)
	end
end)
hud.territoryToggle.Activated:Connect(function()
	hud.showTerritory = not hud.showTerritory
	renderUi()
end)
hud.motionToggle.Activated:Connect(function()
	reduced = not reduced
	renderUi()
end)
hud.left.Activated:Connect(function()
	if phase == "Lobby" then
		send("Queue")
	elseif phase == "Draft" and view then
		send("Select", view.offer[1])
	elseif phase == "Aim" then
		angle = (angle - 15) % 360
		send("Aim", nil, angle)
		renderUi()
	elseif (phase == "RoundResult" or phase == "MatchResult") and #history > 1 then
		replayAt = os.clock()
	end
end)
hud.right.Activated:Connect(function()
	if phase == "Lobby" or phase == "Queued" then
		if phase == "Queued" then
			send("Cancel")
			task.delay(0.25, function()
				send("Practice")
			end)
		else
			send("Practice")
		end
	elseif phase == "Draft" and view then
		send("Select", view.offer[2])
	elseif phase == "Aim" then
		angle = (angle + 15) % 360
		send("Aim", nil, angle)
		renderUi()
	elseif phase == "RoundResult" or phase == "MatchResult" then
		reduced = not reduced
		renderUi()
	end
end)
hud.primary.Activated:Connect(function()
	if phase == "Lobby" then
		reduced = not reduced
		renderUi()
	elseif phase == "Queued" then
		send("Cancel")
	elseif phase == "Draft" then
		send("Commit")
	elseif phase == "Aim" then
		send("AimLock")
	elseif phase == "MatchResult" then
		send("Rematch")
		hud.primary.Text = "REMATCH REQUESTED"
	end
end)
stateRemote.OnClientEvent:Connect(function(raw: unknown)
	if type(raw) ~= "table" then
		return
	end
	local state = raw :: ViewTypes.State
	lastStateAt = os.clock()
	if state.phase == "Lobby" or state.phase == "Queued" then
		view = nil
		phase = state.phase
		replayAt = nil
		renderUi()
		return
	end
	if not view or view.id ~= state.id or view.roundId ~= state.roundId then
		controller = Controller.new()
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
	if not dragging then
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
ack.OnClientEvent:Connect(function(_id: number, accepted: boolean, reason: string)
	if not accepted and reason ~= "duplicate" and reason ~= "rate" then
		hud.status.Text = "Action arrived too late. Showing the server's choice."
		snapshotRequest:FireServer()
	end
end)
local function updateAim(position: Vector2)
	local s = ownSeat()
	local camera = Workspace.CurrentCamera
	if phase ~= "Aim" or not s or s.aimLocked or not camera then
		return
	end
	local nextAngle = Aim.angle(hud.gui.AbsoluteSize, position, s.x, s.z)
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
	if
		input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
	then
		dragging = true
		updateAim(Vector2.new(input.Position.X, input.Position.Y))
	end
end)
UserInputService.InputChanged:Connect(function(input, processed)
	if
		dragging
		and (
			input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch
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
	if
		input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
	then
		dragging = false
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
				positions = Controller.positions(controller, now),
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
		renderUi()
	end
	local positions = Controller.positions(controller, now)
	if view and view.phase ~= "Battle" and view.phase ~= "Overtime" and #controller.samples > 0 then
		positions = controller.samples[#controller.samples].balls
	end
	if replayAt then
		local index = math.floor((now - replayAt) * 10) + 1
		if index > #history then
			replayAt = nil
			Territory.apply(floor, controller.board)
			score(controller.board)
			renderUi()
		else
			local frame = history[index]
			positions = frame.positions
			Territory.apply(floor, frame.board)
			score(frame.board)
			hud.status.Text = "REPLAY · final two seconds · result is already locked"
		end
	end
	Balls.render(balls, positions, view, reduced)
	for i, ball in balls.balls do
		ball.label.Text = string.format("%d%%", math.floor(controller.board.counts[i] / 10.24 + 0.5))
	end
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
			then (1800 - v.tick) / 60
			elseif phase == "Overtime" then (2700 - v.tick) / 60
			else v.deadline - Workspace:GetServerTimeNow()
		local secondsLeft = math.max(0, math.ceil(seconds))
		hud.draftTitle.Text = "CHOOSE YOUR BALL - " .. secondsLeft
		hud.collectionTitle.Text = if phase == "Draft"
			then "Select Any Ball - " .. secondsLeft
			else "Select Any Ball"
		hud.phase.Text = if phase == "Aim"
			then "ADJUST YOUR AIM - " .. secondsLeft
			elseif phase == "Countdown" then "GET READY - " .. secondsLeft
			else "CONNECTING…"
		hud.timer.Text = string.format(
			"%02d:%02d",
			math.max(0, math.ceil(seconds)) // 60,
			math.max(0, math.ceil(seconds)) % 60
		)
		if (phase == "Battle" or phase == "Overtime") and now - controller.lastReceived > 0.75 then
			hud.status.Text = "Connection delayed · waiting for server"
		end
		hud.gui:SetAttribute("Phase", phase)
		hud.gui:SetAttribute("MatchId", v.id)
		hud.gui:SetAttribute("RoundId", v.roundId)
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
