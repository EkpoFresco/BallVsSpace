assert(game:GetService("RunService"):IsStudio(),"Studio only")
game:SetAttribute("BVSAutoTest",true)
game:GetService("Workspace").StreamingEnabled=false
task.spawn(function()
 local result=game:GetService("StudioTestService"):ExecuteMultiplayerTestAsync(2,"BVS normal-clock ten matches")
 game:SetAttribute("BVSAutoTest",nil)
 game:SetAttribute("BVSMultiplayerResult",game:GetService("HttpService"):JSONEncode(result))
 print("BVS MULTIPLAYER FINISHED",game:GetAttribute("BVSMultiplayerResult"))
end)
return "Started two-client normal-clock test; poll Studio instances and logs."
