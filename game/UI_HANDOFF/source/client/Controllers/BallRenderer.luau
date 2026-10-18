--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Shared = game:GetService("ReplicatedStorage").Shared
local Appearances = require(Shared.AppearanceCatalog)
local Protocol = require(Shared.Protocol)
local ViewTypes = require(Shared.ViewTypes)
local Art = require(script.Parent.BallArt)
local Artwork = require(script.Parent.Artwork)
local Layout = require(script.Parent.ReferenceLayout)
local Ui = require(script.Parent.ReferenceUi)
local Renderer = {}
export type Visual = {
	frame: Frame,
	viewport: ViewportFrame,
	model: Model,
	label: TextLabel,
	skin: string,
	aim: { Frame },
	trail: { Frame },
	shadow: Frame,
	pulse: Frame,
	lastAbility: number,
	pulseAt: number,
	positions: { Vector2 },
	lastTrail: number,
	lastPoint: Vector2,
	spin: number,
}
export type State = { gui: ScreenGui, root: Frame, scale: UIScale, balls: { Visual } }
local function circle(parent: Instance, name: string, diameter: number, color: Color3): Frame
	local f = Ui.frame(parent, name, 0, 0, diameter, diameter, color)
	f.AnchorPoint = Vector2.new(0.5, 0.5)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(1, 0)
	c.Parent = f
	return f
end
function Renderer.new(): State
	local gui = Instance.new("ScreenGui")
	gui.Name = "BVSBallLabels"
	gui.IgnoreGuiInset = true
	gui.ScreenInsets = Enum.ScreenInsets.None
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 10
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
	local root, scale = Layout.root(gui)
	local balls: { Visual } = {}
	for i = 1, 2 do
		local aim = {}
		for j = 1, 7 do
			local dash = Ui.frame(root, "Aim" .. i .. "_" .. j, 0, 0, 30, 18, Color3.fromRGB(250, 251, 255))
			dash.AnchorPoint = Vector2.new(0.5, 0.5)
			dash.Visible = false
			if j == 5 then
				dash.BackgroundTransparency = 1
				local head = Artwork.image(dash, "Arrowhead", "Arrow", 0, 0, 30, 54)
				-- Crop the authored triangle from its icon; preserve the measured head proportions.
				head.ImageRectOffset += Vector2.new(12, 10)
				head.ImageRectSize = Vector2.new(104, 108)
				head.ScaleType = Enum.ScaleType.Stretch
			end
			aim[j] = dash
		end
		local trail = {}
		for j = 1, 9 do
			local p = circle(root, "Trail", 23, Color3.fromRGB(100, 231, 9))
			p.Visible = false
			trail[j] = p
		end
		local frame = Ui.frame(root, "Ball" .. i, 0, 0, 246, 246, Color3.new())
		frame.BackgroundTransparency = 1
		frame.AnchorPoint = Vector2.new(0.5, 0.5)
		local shadow = circle(frame, "Shadow", 90, Color3.new())
		shadow.Position = UDim2.fromOffset(120, 121)
		shadow.BackgroundTransparency = 0.93
		for blur = 1, 6 do
			local layer = circle(shadow, "Penumbra", 90 + blur * 3, Color3.new())
			layer.Position = UDim2.fromScale(0.5, 0.5)
			layer.BackgroundTransparency = 0.96
		end
		local pulse = circle(frame, "AbilityPulse", 90, Color3.fromRGB(159, 255, 40))
		pulse.BackgroundTransparency = 0.8
		pulse.Position = UDim2.fromOffset(123, 123)
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(190, 255, 92)
		stroke.Thickness = 3
		stroke.Transparency = 0.3
		stroke.Parent = pulse
		local viewport, model = Art.viewport(frame, "Model", "Acid")
		viewport.Size = UDim2.fromScale(1, 1)
		if viewport.CurrentCamera then
			viewport.CurrentCamera.CFrame = CFrame.new(0, 0, 11.2)
		end
		local label = Ui.text(frame, "Coverage", "", 63, 102, 120, 42, 25)
		local outline = label:FindFirstChild("TextOutline") :: UIStroke
		outline.Thickness = 2.5
		table.insert(balls, {
			frame = frame,
			viewport = viewport,
			model = model,
			label = label,
			skin = "Acid",
			aim = aim,
			trail = trail,
			shadow = shadow,
			pulse = pulse,
			lastAbility = 0,
			pulseAt = -100,
			positions = {},
			lastTrail = 0,
			lastPoint = Vector2.zero,
			spin = 0,
		})
	end
	return { gui = gui, root = root, scale = scale, balls = balls }
end
function Renderer.render(
	state: State,
	positions: { Protocol.Motion },
	view: ViewTypes.State?,
	reduced: boolean
)
	local camera = Workspace.CurrentCamera
	if camera then
		state.scale.Scale = Layout.scale(state.gui.AbsoluteSize)
	end
	local now = os.clock()
	for i, v in state.balls do
		local b = positions[i]
		local seat = if view then view.seats[i] else nil
		local visible = view ~= nil
			and b ~= nil
			and seat ~= nil
			and (
				view.phase == "Aim"
				or view.phase == "Countdown"
				or view.phase == "Battle"
				or view.phase == "Overtime"
			)
		v.frame.Visible = visible
		for _, dash in v.aim do
			dash.Visible = false
		end
		for _, p in v.trail do
			p.Visible = false
		end
		if not visible or not view or not b or not seat then
			table.clear(v.positions)
			continue
		end
		local skin = seat.appearance or Appearances.default(seat.kitId or "Drift")
		if skin ~= v.skin then
			local parent = v.model.Parent
			v.model:Destroy()
			assert(parent, "Ball model lost its viewport")
			v.model = Art.build(parent, skin)
			v.skin = skin
			Art.setSkin(v.viewport, skin)
		end
		local point = Layout.ball(b.x, b.z)
		v.frame.Position = UDim2.fromOffset(point.X, point.Y)
		local battle = view.phase == "Battle" or view.phase == "Overtime"
		local movement = point - v.lastPoint
		if battle and movement.Magnitude < 30 and not reduced then
			v.spin += movement.Magnitude * 0.008
		end
		v.lastPoint = point
		Art.animate(
			v.viewport,
			if skin == "Axe" or skin == "Blade" then 0 else math.deg(v.spin),
			if reduced then -90 else math.deg(now * 3),
			battle
		)
		if v.viewport.ImageTransparency < 1 then
			v.model:PivotTo(
				CFrame.Angles(0, if skin == "Axe" then 0.3 else 0, if skin == "Axe" then 0 else v.spin)
			)
			local weapon = v.model:FindFirstChild("Weapon")
			if weapon and weapon:IsA("Model") then
				weapon:PivotTo(CFrame.Angles(0, 0, if reduced then -math.pi / 2 else now * 3))
				for _, p in weapon:GetChildren() do
					if p:IsA("BasePart") then
						p.Transparency = if battle then 0 else 1
					end
				end
			end
		end
		v.label.Visible = battle
		if b.nextAbilityTick ~= v.lastAbility then
			if v.lastAbility > 0 and b.nextAbilityTick > v.lastAbility then
				v.pulseAt = now
			end
			v.lastAbility = b.nextAbilityTick
		end
		local age = now - v.pulseAt
		v.pulse.Visible = battle and age < 0.65 and not reduced
		v.pulse.Size = UDim2.fromOffset(88 + age * 70, 88 + age * 70)
		v.pulse.BackgroundTransparency = math.clamp(0.72 + age * 0.42, 0, 1)
		if battle and not reduced and now - v.lastTrail > 0.055 then
			table.insert(v.positions, 1, point)
			if #v.positions > 9 then
				table.remove(v.positions)
			end
			v.lastTrail = now
		end
		for j, p in v.trail do
			local old: Vector2? = v.positions[j]
			p.Visible = battle and not reduced and old ~= nil
			if old then
				p.Position = UDim2.fromOffset(old.X + math.sin(j * 2.7) * 12, old.Y + math.cos(j * 3) * 12)
				local size = if skin == "Axe" then 4 + (9 - j) * 0.65 else 8 + (9 - j) * 2.7
				p.Size = UDim2.fromOffset(size, size)
				p.BackgroundTransparency = 0.25 + j * 0.075
				p.BackgroundColor3 = if skin == "Axe"
					then Color3.fromRGB(255, 247, 209)
					else Color3.fromRGB(86, 223, 3)
			end
		end
	end
end
return table.freeze(Renderer)
