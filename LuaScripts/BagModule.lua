local BaseModule = require("Module/BaseModule")
local BagModule = class("BagModule", BaseModule)

function BagModule:ctor(...)
  BagModule.super.ctor(self, ...)
end

function BagModule:onReset()
end

function BagModule:onSetVisible(isVisible)
end

function BagModule:onDestroyUI(uid, uiStack)
end

function BagModule:onPushUI(uid, uiStack)
end

function BagModule:onAfterInitUI(uid, uiStack)
end

function BagModule:onActiveUI(uid, uiStack)
end

function BagModule:onInActiveUI(uid, uiStack)
end

return BagModule
