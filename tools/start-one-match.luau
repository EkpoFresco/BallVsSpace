assert(game:GetService("RunService"):IsStudio(),"Studio only")
game:GetService("Workspace").StreamingEnabled=false
task.spawn(function()
 local result=game:GetService("StudioTestService"):ExecuteMultiplayerTestAsync(2,"BVS normal-clock 1 matches")
 game:SetAttribute("BVSAdditionalMultiplayerResult",game:GetService("HttpService"):JSONEncode(result))
 print("BVS ADDITIONAL MULTIPLAYER FINISHED",game:GetAttribute("BVSAdditionalMultiplayerResult"))
end)
return "Started one additional normal-clock two-client match."
