if not CS.LuaManager.HOTFIX_ENABLE then
  return
end
local hotfix = require("hotfix/hotfix")
hotfix("HotFixTest", require("hotfix/HotFixTest"))
