local svc=game:GetService("StudioDeviceSimulatorService")
local out={orientation=tostring(game:GetService("StarterGui").ScreenOrientation),devices={}}
for _,id in svc:GetDeviceListAsync() do
 local info=svc:GetDeviceInfoAsync(id)
 if string.find(info.Name,"iPhone") or string.find(info.Name,"Galaxy") then
  table.insert(out.devices,{id=id,name=info.Name})
 end
end
return out
