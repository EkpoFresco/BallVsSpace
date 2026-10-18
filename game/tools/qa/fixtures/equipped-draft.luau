local g=game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace
local inventory=g.ReferenceCanvas.Panels.Inventory
assert(inventory.BallsPage.Details.Equipped.Text=="Equipped: Verity", "Equip feedback")
local first=g.ReferenceCanvas.Draft:FindFirstChild("Verity")
assert(first and first:IsA("TextButton"), "Equipped ball available as draft card")
return {equipped="Verity",offeredInDraft=true,selectionStillExplicit=true}
