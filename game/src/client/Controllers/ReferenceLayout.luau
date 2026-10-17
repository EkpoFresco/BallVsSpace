--!strict
local Layout = {}
Layout.width = 803
Layout.height = 602
Layout.court = Vector2.new(145, 45)
Layout.inner = Vector2.new(178, 78)
Layout.innerSize = 446
function Layout.scale(size: Vector2): number
	return math.min(size.Y / 602, size.X / (if size.X < size.Y then 570 else 803))
end
function Layout.root(parent: Instance): (Frame, UIScale)
	local root = Instance.new("Frame")
	root.Name = "ReferenceCanvas"
	root.Size = UDim2.fromOffset(803, 602)
	root.AnchorPoint = Vector2.new(0.5, 0.5)
	root.Position = UDim2.fromScale(0.5, 0.5)
	root.BackgroundTransparency = 1
	root.Parent = parent
	local scale = Instance.new("UIScale")
	scale.Parent = root
	return root, scale
end
function Layout.ball(x: number, z: number): Vector2
	-- The reference shell is 82 / 446 of the court width. Keep that entire
	-- shell inside the visual walls, independently of the territory solver.
	return Vector2.new(401 + x * 446 / 64, 301 + z * 446 / 64)
end
function Layout.screenToCanvas(screen: Vector2, viewport: Vector2): Vector2
	return (screen - viewport / 2) / Layout.scale(viewport) + Vector2.new(401.5, 301)
end
return table.freeze(Layout)
