local BaseObject = require("Base/BaseObject")
local BaseManagerHelper = class("BaseManagerHelper", BaseObject)

function BaseManagerHelper:ctor(...)
  self:initComponent()
  self:doEvent("OnCreate", ...)
end

function BaseManagerHelper:initComponent()
  BaseManagerHelper.super.initComponent(self)
  self:addComponent("GameEvent")
end

function BaseManagerHelper:dispose()
  if not self._disposed then
    self._dispose = true
    self:removeAllComponent()
    self:doEvent("OnDestroy")
  end
end

return BaseManagerHelper
