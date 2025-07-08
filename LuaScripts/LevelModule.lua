local BaseModule = require("Module/BaseModule")
local LevelModule = class("LevelModule", BaseModule)

function LevelModule:ctor(...)
  LevelModule.super.ctor(self, ...)
end

function LevelModule:onReset()
end

function LevelModule:onSetVisible(isVisible)
end

function LevelModule:onDestroyUI(uid, uiStack)
end

function LevelModule:onPushUI(uid, uiStack)
end

function LevelModule:onAfterInitUI(uid, uiStack)
end

function LevelModule:onActiveUI(uid, uiStack)
end

function LevelModule:onInActiveUI(uid, uiStack)
end

function LevelModule:onDestroyUI(uid, uiStack)
end

return LevelModule
