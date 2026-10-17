local r={}
for _,c in workspace:GetChildren() do if c:IsA("Camera") then table.insert(r,{name=c.Name,current=c==workspace.CurrentCamera,viewport=tostring(c.ViewportSize),cf=tostring(c.CFrame),type=tostring(c.CameraType)}) end end
return {cameras=r,running=game:GetService("RunService"):IsRunning(),client=game:GetService("RunService"):IsClient(),player=game:GetService("Players").LocalPlayer.Name,now=workspace:GetServerTimeNow()}
