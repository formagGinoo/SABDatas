local BaseModule = require("Module/BaseModule")
local MailModule = class("MailModule", BaseModule)

function MailModule:ctor(...)
  MailModule.super.ctor(self, ...)
end

function MailModule:onReset()
end

function MailModule:onSetVisible(isVisible)
end

function MailModule:onDestroyUI(uid, uiStack)
end

function MailModule:onPushUI(uid, uiStack)
end

function MailModule:onAfterInitUI(uid, uiStack)
end

function MailModule:onActiveUI(uid, uiStack)
end

function MailModule:onInActiveUI(uid, uiStack)
end

return MailModule
