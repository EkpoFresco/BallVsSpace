--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Shared = ReplicatedStorage:WaitForChild("Shared", 15)
assert(Shared, "Missing shared modules")
local Catalog = require(Shared.BallCatalog)
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
local function send(kind: string, kit: string?, direction: number?)
	id += 1
	local v = view
	command:FireServer({
		id = id,
		kind = kind,
		matchId = if v then v.id else "",
		roundId = if v then v.roundId else 0,
		generation = if v then v.generation else 0,
		kitId = kit,
		angle = direction,
	})
end
local function score(board: Types.Board)
	hud.scoreA.Text = string.format("◇ %.1f%%", 100 * board.counts[1] / 1024)
	hud.scoreB.Text = string.format("%.1f%% ○", 100 * board.counts[2] / 1024)
	hud.barA.Size = UDim2.fromScale(board.counts[1] / 1024, 1)
	hud.barB.Size = UDim2.fromScale(board.counts[2] / 1024, 1)
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
	local v = view
	local own = ownSeat()
	hud.left.Visible = true
	hud.right.Visible = true
	hud.primary.Visible = true
	hud.help.Visible = phase == "Lobby" or phase == "Queued" or phase == "Draft" or phase == "Aim"
	hud.primary.Active = true
	hud.primary.AutoButtonColor = true
	if not v then
		hud.phase.Text = "BALL VS SPACE"
		hud.timer.Text = "ORBITAL COURT"
		hud.points.Text = "Most space at the buzzer wins"
		hud.left.Text = "PLAY 1V1"
		hud.right.Text = "PRACTICE"
		hud.primary.Text = if phase == "Queued"
			then "CANCEL QUEUE"
			else (if reduced then "REDUCED MOTION: ON" else "REDUCED MOTION: OFF")
		hud.hint.Text = if phase == "Queued"
			then "Waiting for another player…"
			else "Pick your ball. Aim your opening.\nTake the most space."
		hud.status.Text = "M1 prototype · two kits · session only"
		return
	end
	hud.phase.Text = string.upper(phase) .. " · ROUND " .. v.roundNumber .. " / 3"
	hud.points.Text = string.format(
		"POINTS  %g — %g   ·   %d neutral cells",
		v.points2[1] / 2,
		v.points2[2] / 2,
		controller.board.counts[0]
	)
	hud.status.Text = (
		if v.practice then "PRACTICE · no competitive rewards" else "1V1 · session-only prototype"
	) .. (if own then " · You: " .. (if own.team == 1 then "◇ CYAN" else "○ CORAL") else "")
	if phase == "Draft" then
		for i, button in { hud.left, hud.right } do
			local kit = Catalog.kits[v.offer[i]]
			if kit then
				button.Text = kit.id .. "\n" .. kit.role
				button.BackgroundColor3 = if kit.id == v.localKit
					then Color3.fromRGB(43, 100, 111)
					else Color3.fromRGB(40, 56, 74)
			end
		end
		hud.hint.Text = if v.localKit ~= "" then Catalog.kits[v.localKit].description else "Choose a ball"
		hud.primary.Text = if own and own.pickLocked
			then "CHOICE LOCKED"
			else "LOCK " .. string.upper(v.localKit)
	elseif phase == "Aim" then
		hud.hint.Text = "Drag on the court to aim.\nThe line previews your first wall bounce."
		hud.left.Text = "↶  TURN 15°"
		hud.right.Text = "TURN 15°  ↷"
		hud.primary.Text = if own and own.aimLocked
			then "AIM LOCKED"
			else string.format("LOCK AIM · %03d°", angle)
	elseif phase == "RoundResult" or phase == "MatchResult" then
		local winner = if v.winner == 0
			then "DRAW"
			elseif v.winner == 1 then "◇ CYAN WINS"
			else "○ CORAL WINS"
		hud.hint.Text = winner
			.. "\n"
			.. controller.board.counts[1]
			.. " — "
			.. controller.board.counts[2]
			.. " cells · final area decides"
		if v.reason ~= "final_area" and v.reason ~= "match_points" and v.reason ~= "overtime_draw" then
			hud.hint.Text = winner .. "\n" .. string.gsub(v.reason, "_", " ")
		end
		hud.left.Text = "WATCH LAST 2s"
		hud.right.Text = if reduced then "MOTION: REDUCED" else "MOTION: FULL"
		hud.primary.Text = if phase == "MatchResult" then "REMATCH" else "NEXT ROUND SOON"
	elseif phase == "Overtime" then
		hud.hint.Text = "OVERTIME\nLead by 2+ cells for 10 updates (1 second)."
		hud.left.Visible = false
		hud.right.Visible = false
		hud.primary.Text = "AUTOMATIC BATTLE"
	elseif phase == "Battle" or phase == "Countdown" then
		hud.hint.Text = if phase == "Countdown"
			then "Most space at the buzzer wins."
			else "Keep covering to strengthen.\nEnemy coverage steals."
		hud.left.Visible = false
		hud.right.Visible = false
		hud.primary.Text = if phase == "Countdown" then "GET READY" else "AUTOMATIC BATTLE"
	else
		hud.hint.Text = "Connecting players…"
		hud.left.Visible = false
		hud.right.Visible = false
		hud.primary.Text = "READY CHECK"
	end
end
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
	local nextAngle = Aim.angle(camera, position, s.x, s.z)
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
		Camera.fit(camera)
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
renderUi()
print("BVS CLIENT READY")
