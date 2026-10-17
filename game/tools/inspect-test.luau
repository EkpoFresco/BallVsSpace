local p=game:GetService("Players")
local users={}
for _,v in p:GetPlayers() do table.insert(users,{id=v.UserId,name=v.Name}) end
local g=p.LocalPlayer and p.LocalPlayer.PlayerGui:FindFirstChild("BallVsSpace")
return {isServer=game:GetService("RunService"):IsServer(),localPlayer=p.LocalPlayer and p.LocalPlayer.UserId,players=users,auto=game:GetAttribute("BVSAutoTest"),workspace=workspace:GetAttributes(),gui=g and g:GetAttributes()}
