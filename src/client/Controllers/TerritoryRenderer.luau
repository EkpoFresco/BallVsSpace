--!strict
local Workspace = game:GetService("Workspace")
local Shared = game:GetService("ReplicatedStorage").Shared
local Arena = require(Shared.ArenaDefinition)
local Types = require(Shared.Types)
local Renderer = {}
local colors = { Color3.fromRGB(57, 214, 230), Color3.fromRGB(250, 124, 111) }
local neutral = Color3.fromRGB(45, 53, 68)
export type State = { tiles: { Part }, q: buffer, folder: Folder }
function Renderer.new(): State
	local root = Instance.new("Folder")
	root.Name = "BVSTerritory"
	root.Parent = Workspace
	local tiles = {}
	for i = 0, 1023 do
		local x, z = Arena.center(i)
		local p = Instance.new("Part")
		p.Name = "Cell_" .. i
		p.Size = Vector3.new(1.93, 0.12, 1.93)
		p.Position = Vector3.new(x, 0, z)
		p.Anchored = true
		p.CanCollide = false
		p.CanQuery = false
		p.CanTouch = false
		p.CastShadow = false
		p.Material = Enum.Material.SmoothPlastic
		p.Color = neutral
		p.Parent = root
		tiles[i + 1] = p
	end
	return { tiles = tiles, q = buffer.create(1024), folder = root }
end
function Renderer.apply(state: State, board: Types.Board)
	for i = 0, 1023 do
		local q = buffer.readi8(board.q, i)
		if q ~= buffer.readi8(state.q, i) then
			local p = state.tiles[i + 1]
			p.Color = if q == 0
				then neutral
				else colors[if q > 0 then 1 else 2]:Lerp(
					Color3.new(0, 0, 0),
					1 - (0.55 + 0.15 * math.abs(q))
				)
			p.Size = Vector3.new(
				if math.abs(q) == 3 then 1.96 else 1.9,
				0.12,
				if math.abs(q) == 3 then 1.96 else 1.9
			)
		end
	end
	buffer.copy(state.q, 0, board.q)
end
return table.freeze(Renderer)
