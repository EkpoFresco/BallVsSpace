local g = game:GetService("Players").LocalPlayer.PlayerGui.BallVsSpace
assert(g:GetAttribute("Phase") == "MatchResult", "Expected completed normal match")
local r = g.ReferenceCanvas
assert(r.Results.Visible and not r.Panels.Visible and not r.Collection.Visible)
return {
 phase = g:GetAttribute("Phase"),
 tick = workspace:GetAttribute("BVSTick"),
 a = workspace:GetAttribute("BVSCountA"),
 b = workspace:GetAttribute("BVSCountB"),
 reason = workspace:GetAttribute("BVSResultReason"),
 title = r.Results.ResultTitle.Text,
}
