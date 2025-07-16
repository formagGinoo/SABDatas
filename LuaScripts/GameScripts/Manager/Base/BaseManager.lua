local BaseObject = require("Base/BaseObject")
local Singleton = require("Base/Singleton")
local meta = class("BaseManager", BaseObject, Singleton)

function meta:ctor(...)
  self:initComponent()
  self:doEvent("OnCreate", ...)
end

function meta:initComponent()
  meta.super.initComponent(self)
  self:addComponent("GameEvent")
  self:addComponent("GameScheduler")
end

function meta:initLoginPush()
  self:doEvent("OnInitLoginPush")
end

function meta:initNetwork()
  self:doEvent("OnInitNetwork")
end

function meta:update(dt)
  self:doEvent("OnUpdate", dt)
end

function meta:dailyReset()
  self:doEvent("OnDailyReset")
end

function meta:dailyZeroReset()
  self:doEvent("OnDailyZeroReset")
end

function meta:dispose()
  if not self._disposed then
    self._dispose = true
    self:removeAllComponent()
    self:doEvent("OnDestroy")
  end
end

function meta:initFetchMoreDataMustFail(messageId, msg)
  local detail = "FetchMoreServerDataFail: Error MessageId:  " .. tostring(messageId) .. "   Error rspCode:  " .. tostring(msg.rspcode)
  ReportManager:ReportLoginProcess("FetchMoreServerDataFail", detail)
  log.error(detail)
  self:doEvent("OnInitFetchMoreDataMustFail", messageId, msg)
end

return meta
