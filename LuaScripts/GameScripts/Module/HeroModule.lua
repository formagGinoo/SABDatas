local BaseModule = require("Module/BaseModule")
local HeroModule = class("HeroModule", BaseModule)

function HeroModule:ctor(...)
  HeroModule.super.ctor(self, ...)
end

function HeroModule:onReset()
end

function HeroModule:onSetVisible(isVisible)
end

function HeroModule:onDestroyUI(uid, uiStack)
end

function HeroModule:onPushUI(uid, uiStack)
end

function HeroModule:onAfterInitUI(uid, uiStack)
end

function HeroModule:onActiveUI(uid, uiStack)
end

function HeroModule:onInActiveUI(uid, uiStack)
end

function HeroModule:onDestroyUI(uid, uiStack)
end

return HeroModule
