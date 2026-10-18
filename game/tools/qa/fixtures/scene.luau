local scene=game:GetService("SceneAnalysisService")
local result={phase=workspace:GetAttribute("BVSPhase"),placeId=game.PlaceId}
for _, method in {"GetInstanceCompositionAsync","GetTriangleCompositionAsync","GetScriptMemoryAsync","GetUnparentedInstancesAsync","GetAnimationMemoryAsync","GetAudioMemoryAsync"} do
 local ok,value=pcall(function()return scene[method](scene)end)
 result[method]=if ok then value else {unavailable=tostring(value)}
end
local player=game:GetService("Players").LocalPlayer
local counts={}
for _, gui in player.PlayerGui:GetChildren() do
 if gui.Name:match("^BVS") or gui.Name=="BallVsSpace" then
  local n={descendants=#gui:GetDescendants(),parts=0,images=0,frames=0}
  for _,item in gui:GetDescendants() do
   if item:IsA("BasePart") then n.parts+=1 elseif item:IsA("ImageLabel") then n.images+=1 elseif item:IsA("Frame") then n.frames+=1 end
  end
  counts[gui.Name]=n
 end
end
result.projectUi=counts
return result
