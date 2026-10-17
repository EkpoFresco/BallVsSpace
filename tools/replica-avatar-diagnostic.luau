local g=game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace.ReferenceCanvas
local out={}
for i=1,2 do local v=g["PlayerSide"..i].PlayerFigure;local w=v:FindFirstChildOfClass("WorldModel");local m=w and w:FindFirstChildOfClass("Model");local box,size;if m then box,size=m:GetBoundingBox() end;out[i]={user=v:GetAttribute("UserId"),model=m and m.Name,box=tostring(box),size=tostring(size),camera=tostring(v.CurrentCamera.CFrame)} end
local s=Instance.new("Sky");out.defaultSky={bk=s.SkyboxBk,ft=s.SkyboxFt,up=s.SkyboxUp};s:Destroy()
return out
