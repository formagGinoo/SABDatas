local BaseModule = require("Module/BaseModule")
local MainModule = class("MainModule", BaseModule)

function MainModule:ctor(...)
  MainModule.super.ctor(self, ...)
end

function MainModule:onReset()
end

function MainModule:onSetVisible(isVisible)
end

function MainModule:onDestroyUI(uid, uiStack)
end

function MainModule:onPushUI(uid, uiStack)
end

function MainModule:onAfterInitUI(uid, uiStack)
end

function MainModule:onActiveUI(uid, uiStack)
end

function MainModule:onInActiveUI(uid, uiStack)
end

return MainModule
