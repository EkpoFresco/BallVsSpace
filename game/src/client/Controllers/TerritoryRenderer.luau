--!strict
local Players = game:GetService("Players")
local Types = require(game:GetService("ReplicatedStorage").Shared.Types)
local Layout = require(script.Parent.ReferenceLayout)
local Ui = require(script.Parent.ReferenceUi)
local Artwork = require(script.Parent.Artwork)
local Renderer = {}
local colors = { Color3.fromRGB(57, 214, 230), Color3.fromRGB(250, 124, 111) }
local neutral = Ui.actionColors.card
local shades: { [number]: Color3 } = { [0] = neutral }
for q = -3, 3 do
	if q ~= 0 then
		shades[q] = colors[if q > 0 then 1 else 2]:Lerp(neutral, 0.45 - math.abs(q) * 0.08)
	end
end
export type State = { tiles: { Frame }, q: buffer, gui: ScreenGui, scale: UIScale, lastBuffer: buffer? }
function Renderer.new(): State
	local gui = Instance.new("ScreenGui")
	gui.Name = "BVSTerritory"
	gui.IgnoreGuiInset = true
	gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
	gui.DisplayOrder = 2
	gui.ResetOnSpawn = false
	gui.Enabled = false
	gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui", 10)
	local root, scale = Layout.root(gui)
	local tiles = {}
	for i = 0, 1023 do
		local p = Ui.frame(
			root,
			"Cell" .. i,
			178 + i % 32 * 446 / 32,
			78 + (i // 32) * 446 / 32,
			446 / 32 + 0.2,
			446 / 32 + 0.2,
			Color3.new()
		)
		p.BackgroundTransparency = 0
		p.BackgroundColor3 = neutral
		tiles[i + 1] = p
	end
	-- One transparent authored overlay replaces 1,024 Frames, corners and strokes.
	local studs = Instance.new("ImageLabel")
	studs.Name = "StudOverlay"
	studs.Image = Artwork.studAsset
	studs.BackgroundTransparency = 1
	studs.Position = UDim2.fromOffset(178, 78)
	studs.Size = UDim2.fromOffset(446, 446)
	studs.ZIndex = 2
	studs.Parent = root
	return { tiles = tiles, q = buffer.create(1024), gui = gui, scale = scale, lastBuffer = nil }
end
function Renderer.apply(state: State, board: Types.Board)
	-- Decoded client boards are immutable; replay may draw the same one repeatedly.
	if state.lastBuffer == board.q then
		return
	end
	for i = 0, 1023 do
		local q = buffer.readi8(board.q, i)
		if q ~= buffer.readi8(state.q, i) then
			local p = state.tiles[i + 1]
			p.BackgroundColor3 = shades[q]
		end
	end
	buffer.copy(state.q, 0, board.q)
	state.lastBuffer = board.q
end
return table.freeze(Renderer)
