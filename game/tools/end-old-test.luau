assert(game.PlaceId==0,"Local test only")
assert(require(game:GetService("ReplicatedStorage").Shared.Config).BuildVersion=="0.1.0-m1","Unexpected test build")
task.defer(function()game:GetService("StudioTestService"):EndTest("Replaced by reference presentation build")end)
return "Ending verified old BallVsSpace multiplayer test"
