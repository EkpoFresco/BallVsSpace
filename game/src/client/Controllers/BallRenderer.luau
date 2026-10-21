--!strict
local Players = game:GetService("Players")
local Shared = game:GetService("ReplicatedStorage").Shared
local Protocol = require(Shared.Protocol)
local Types = require(Shared.Types)
local ViewTypes = require(Shared.ViewTypes)
local Weapon = require(Shared.WeaponGeometry)
local Art = require(script.Parent.BallArt)
local Artwork = require(script.Parent.Artwork)
local Layout = require(script.Parent.ReferenceLayout)
local Ui = require(script.Parent.ReferenceUi)
local WeaponArt = require(script.Parent.WeaponArt)
local Renderer = {}
type Visual = {
	frame: Frame,
	viewport: ViewportFrame,
	model: Model,
	label: TextLabel,
	skin: string,
	aim: { Frame },
	edges: { WeaponArt.Stroke },
	assembly: WeaponArt.Assembly,
	feedback: TextLabel,
	hitRing: UIStroke,
	lastHp: number?,
	lastGuard: number?,
	feedbackAt: number,
}
export type State = {
	gui: ScreenGui,
	root: Frame,
	scale: UIScale,
	balls: { Visual },
	lastTick: number,
	roundKey: string,
}
function Renderer.new(): State
	local gui = Instance.new("ScreenGui")
	gui.Name = "BVSBallLabels"
	gui.Enabled = false
	gui.IgnoreGuiInset = true
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	gui.DisplayOrder = 10
	gui.ResetOnSpawn = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
	local root, scale = Layout.root(gui)
	local field = Ui.frame(root, "WeaponField", 178, 78, 446, 446, Color3.new())
	field.BackgroundTransparency = 1
	field.ClipsDescendants = true
	local balls: { Visual } = {}
	for i = 1, 2 do
		local aim: { Frame } = {}
		for n = 1, 7 do
			local dash = Ui.frame(root, "Aim" .. i .. "_" .. n, 0, 0, 5, 5, Color3.fromRGB(255, 242, 188))
			dash.AnchorPoint = Vector2.new(0.5, 0.5)
			dash.Visible = false
			if n == 5 then
				local icon = Artwork.image(dash, "ArrowHead", "Arrow", 0, 0, 1, 1)
				icon.Size = UDim2.fromScale(1, 1)
				dash.BackgroundTransparency = 1
			end
			table.insert(aim, dash)
		end
		local assembly = WeaponArt.new(field, "Ball" .. i)
		local frame = Ui.frame(root, "Ball" .. i, 0, 0, 48, 48, Color3.new())
		frame.BackgroundTransparency = 1
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		frame.ZIndex = 4
		local viewport, model = Art.viewport(frame, "Model", "Astra")
		viewport.Size = UDim2.fromScale(1, 1)
		viewport:SetAttribute("BodyOnly", true)
		Art.setSkin(viewport, "Astra")
		local label = Ui.text(frame, "Knockout", "KO", -5, 14, 58, 24, 18, true)
		label.Visible = false
		label.ZIndex = 6
		local ring = Ui.frame(frame, "HitRing", 2, 2, 44, 44, Color3.new())
		ring.BackgroundTransparency = 1
		ring.ZIndex = 5
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(1, 0)
		corner.Parent = ring
		local hitRing = Instance.new("UIStroke")
		hitRing.Color = Color3.fromRGB(255, 245, 218)
		hitRing.Thickness = 2
		hitRing.Transparency = 1
		hitRing.Parent = ring
		local feedback = Ui.text(frame, "HitFeedback", "", -18, -24, 84, 24, 17, true)
		feedback.ZIndex = 7
		feedback.Visible = false
		table.insert(balls, {
			frame = frame,
			viewport = viewport,
			model = model,
			label = label,
			skin = "Astra",
			aim = aim,
			edges = assembly.edges,
			assembly = assembly,
			feedback = feedback,
			hitRing = hitRing,
			lastHp = nil,
			lastGuard = nil,
			feedbackAt = -100,
		})
	end
	return { gui = gui, root = root, scale = scale, balls = balls, lastTick = -1, roundKey = "" }
end
function Renderer.render(
	state: State,
	positions: { Protocol.Motion },
	view: ViewTypes.State?,
	reduced: boolean,
	poseTick: number?
)
	local visible = view ~= nil
		and (view.phase == "Aim" or view.phase == "Countdown" or view.phase == "Battle")
	state.gui.Enabled = visible
	state.scale.Scale = Layout.scale(state.gui.AbsoluteSize)
	if not view or not visible then
		state.lastTick = -1
		return
	end
	local tick = poseTick or view.tick
	local roundKey = tostring(view.id) .. ":" .. tostring(view.roundId)
	local reset = state.lastTick < 0 or tick < state.lastTick or state.roundKey ~= roundKey
	state.lastTick, state.roundKey = tick, roundKey
	local now = os.clock()
	for i, v in state.balls do
		local seat = view.seats[i]
		if not seat then
			v.frame.Visible = false
			v.assembly.tail.Visible = false
			v.assembly.guard.Visible = false
			for _, edge in v.edges do
				edge.edge.Visible = false
				edge.handle.Visible = false
			end
			continue
		end
		local p = positions[i]
		local x, z = if p then p.x else seat.x, if p then p.z else seat.z
		local w: Types.WeaponState = if p then table.clone(p.weapon) else (seat.weapon or Weapon.new(x, z, 0))
		-- Reliable state prevents a dropped final motion packet from resurrecting HP.
		if seat.weapon then
			w.hp = seat.weapon.hp
		end
		local id = seat.kitId or "Astra"
		if v.skin ~= id then
			v.skin = id
			Art.setSkin(v.viewport, id)
		end
		v.frame.Visible = true
		local center = Layout.ball(x, z)
		v.frame.Position = UDim2.fromOffset(center.X, center.Y)
		v.label.Visible = w.hp <= 0
		if reset then
			v.lastHp, v.lastGuard, v.feedbackAt = nil, nil, -100
		end
		if view.phase == "Battle" and v.lastHp ~= nil then
			local change = w.hp - v.lastHp
			local guarded = v.lastGuard ~= nil and w.guardReadyTick > v.lastGuard
			if change ~= 0 or guarded then
				v.feedback.Text = if change > 0
					then "+" .. change
					elseif change < 0 then tostring(change)
					else "BLOCK"
				v.feedback.TextColor3 = if change > 0 then Ui.actionColors.cyan else Ui.actionColors.paper
				v.feedbackAt = now
			end
		end
		v.lastHp, v.lastGuard = w.hp, w.guardReadyTick
		local age = now - v.feedbackAt
		v.feedback.Visible = age < 0.6
		if age < 0.6 then
			v.feedback.Position = UDim2.fromOffset(-18, -24 - (if reduced then 0 else age * 12))
			v.feedback.TextTransparency = math.clamp((age - 0.3) / 0.3, 0, 1)
		end
		v.hitRing.Transparency = if reduced then 1 else math.clamp(age / 0.25, 0, 1)
		for _, dash in v.aim do
			dash.Visible = view.phase == "Aim" or view.phase == "Countdown"
		end
		WeaponArt.draw(
			v.assembly,
			id,
			x,
			z,
			w.angle,
			Weapon.sample(id, x, z, seat.team, w, tick),
			1 / 64,
			0.5,
			0.5,
			w.guardReadyTick > tick
		)
	end
end
return table.freeze(Renderer)
