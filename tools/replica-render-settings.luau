local data={}
for _,key in {"QualityLevel","EditQualityLevel","EnableFRM","MeshCacheSize","EagerBulkExecution"} do
local ok,value=pcall(function()return settings().Rendering[key]end)
data[key]=if ok then tostring(value) else tostring(value)
end
local settingsObject=settings().Rendering
local ok,value=pcall(function()return settingsObject:GetChildren()end)
data.children=if ok then #value else tostring(value)
return data
