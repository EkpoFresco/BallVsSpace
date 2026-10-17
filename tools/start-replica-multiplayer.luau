assert(game.PlaceId==0,"Local development only")
task.spawn(function()
local result=game:GetService("StudioTestService"):ExecuteMultiplayerTestAsync(2,"BVS normal-clock 1 matches")
game:SetAttribute("BVSReplicaMultiplayerResult",game:GetService("HttpService"):JSONEncode(result))
print("BVS REPLICA MULTIPLAYER FINISHED",game:GetAttribute("BVSReplicaMultiplayerResult"))
end)
return "Started two real clients for reference-build regression"
