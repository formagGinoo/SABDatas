local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")
local handler2 = 0
local handler3 = 0

function TestFunc2(arg1, arg2, arg3, arg4)
  print("testfunc2", arg1, arg2, arg3, arg4)
  EventCenter.Broadcast(EventDefine.eGameEvent_Test2, arg1 + 1, arg2 + 1, arg3 + 1, arg4 + 1)
end

function TestFunc3(arg1, arg2, arg3, arg4)
  print("testfunc3", arg1, arg2, arg3, arg4)
end

handler2 = EventCenter.AddListener(EventDefine.eGameEvent_Test1, TestFunc2)
handler3 = EventCenter.AddListener(EventDefine.eGameEvent_Test1, TestFunc3)
