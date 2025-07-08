local BaseModule = require("Module/BaseModule")
local CardModule = class("CardModule", BaseModule)

function CardModule:ctor(...)
  CardModule.super.ctor(self, ...)
end

function CardModule:onReset()
end

function CardModule:onSetVisible(isVisible)
end

function CardModule:onDestroyUI(uid, uiStack)
end

function CardModule:onPushUI(uid, uiStack)
end

function CardModule:onAfterInitUI(uid, uiStack)
end

function CardModule:onActiveUI(uid, uiStack)
end

function CardModule:onInActiveUI(uid, uiStack)
end

return CardModule
