local BaseModule = require("Module/BaseModule")
local OtherModule = class("OtherModule", BaseModule)

function OtherModule:ctor(...)
  OtherModule.super.ctor(self, ...)
end

function OtherModule:onReset()
end

function OtherModule:onSetVisible(isVisible)
end

function OtherModule:onDestroyUI(uid, uiStack)
end

function OtherModule:onPushUI(uid, uiStack)
end

function OtherModule:onAfterInitUI(uid, uiStack)
end

function OtherModule:onActiveUI(uid, uiStack)
end

function OtherModule:onInActiveUI(uid, uiStack)
end

return OtherModule
