--!strict
local Players = game:GetService("Players")
local Types = require(game:GetService("ReplicatedStorage").Shared.Types)
local Layout = require(script.Parent.ReferenceLayout)
local Ui = require(script.Parent.ReferenceUi)
local Renderer = {}
local colors = { Color3.fromRGB(57, 214, 230), Color3.fromRGB(250, 124, 111) }
export type State = { tiles: { Frame }, q: buffer, gui: ScreenGui, scale: UIScale }
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
		p.BackgroundTransparency = 1
		tiles[i + 1] = p
	end
	return { tiles = tiles, q = buffer.create(1024), gui = gui, scale = scale }
end
function Renderer.apply(state: State, board: Types.Board)
	for i = 0, 1023 do
		local q = buffer.readi8(board.q, i)
		if q ~= buffer.readi8(state.q, i) then
			local p = state.tiles[i + 1]
			p.BackgroundTransparency = if q == 0 then 1 else 0.60 - math.abs(q) * 0.1
			p.BackgroundColor3 = colors[if q >= 0 then 1 else 2]
		end
	end
	buffer.copy(state.q, 0, board.q)
end
return table.freeze(Renderer)
