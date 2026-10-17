local s=game:GetService("ReplicatedStorage"):FindFirstChild("Shared")
return {name=game.Name,placeId=game.PlaceId,gameId=game.GameId,source=s and s:FindFirstChild("Config") and s.Config.Source,playing=game:GetService("RunService"):IsRunning()}
