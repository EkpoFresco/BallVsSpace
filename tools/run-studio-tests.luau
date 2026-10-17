local suite=require(game:GetService("ServerScriptService").Server.Tests.Suite)
local started=os.clock()
local results=suite.run()
return {passed=#results,tests=results,seconds=os.clock()-started}
