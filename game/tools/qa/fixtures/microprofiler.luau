local LibMP = require("@rbx/LibMP")
assert(LibMP.Control:IsBackendReady(), "MicroProfiler backend unavailable")
LibMP.Control:SetFrameLimit(128)
LibMP.Control:EnableProfiler(true)
LibMP.Control:EnableCapture(true)
task.wait(2.5)
local snapshot = LibMP.Control:CaptureToBufferSync()
local session = LibMP.Session.OpenFromBuffer(snapshot)
assert(session and session:IsValid(), "Invalid MicroProfiler snapshot")
local ok,result=pcall(function()
 local first,last=session:GetFrameIdMin(),session:GetFrameIdMax()
 local factor=session:FetchGlobalDesc().TickToMsCpu
 local samples={}
 for id=first,last do
  local f=session:FetchFrameDesc(id)
  if not f.IsIncomplete and f.TickEndCpu>=f.TickStartCpu then
   table.insert(samples,{id=id,absoluteId=f.FrameAbsoluteId,ms=(f.TickEndCpu-f.TickStartCpu)*factor})
  end
 end
 assert(#samples>0,"No complete frames")
 table.sort(samples,function(a,b)return a.ms<b.ms end)
 local scopes={}
 for _,id in session:FindTimerIds("*BVS*") do
  table.insert(scopes,session:FetchTimerDesc(id).TimerName)
 end
 return {frames=#samples,median=samples[math.ceil(#samples*.5)],p95=samples[math.ceil(#samples*.95)],maximum=samples[#samples],snapshotBytes=buffer.len(snapshot),scopes=scopes,phase=workspace:GetAttribute("BVSPhase"),note="CPU frame intervals in this Studio session; includes engine/editor work, not device certification"}
end)
session:Dispose()
LibMP.Control:EnableCapture(true)
LibMP.Control:EnableProfiler(false)
assert(ok,result)
return result
