local w=workspace
local c=w.CurrentCamera
local t=w:FindFirstChild("BVSTerritory")
local b=w:FindFirstChild("BVSBalls")
local values={camera=tostring(c.CFrame),focus=tostring(c.Focus),viewport=tostring(c.ViewportSize),streaming=w.StreamingEnabled,court=w:FindFirstChild("BVSCourt")~=nil,ballCount=b and #b:GetChildren()}
if t then
 local p=t.Cell_500
 local screen,visible=c:WorldToViewportPoint(p.Position)
 values.tile={screen=tostring(screen),visible=visible,transparency=p.Transparency,color=tostring(p.Color),position=tostring(p.Position),size=tostring(p.Size),localTransparency=p.LocalTransparencyModifier}
end
if b then values.label={visible=b.Ball1.Identity.TextLabel.Visible,text=b.Ball1.Identity.TextLabel.Text,enabled=b.Ball1.Identity.Enabled} end
return values
