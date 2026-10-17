assert(game.PlaceId==0,"Local development place only")
local c=game:GetService("StarterPlayer").StarterPlayerScripts.Client.Controllers
for _,name in {"ReferenceHud","ReferenceBalls","ReferenceAim","ReferenceCamera","ReferenceTerritory"} do local m=c:FindFirstChild(name);if m then assert(m:IsA("ModuleScript"),"Unexpected instance class");m:Destroy()end end
local m=game:GetService("ServerScriptService").Server.Services:FindFirstChild("ReferenceWorld");if m then assert(m:IsA("ModuleScript"),"Unexpected instance class");m:Destroy()end
return "Removed six superseded project modules after canonical replacements"
