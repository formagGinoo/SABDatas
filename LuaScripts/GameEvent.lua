local BaseComponent = require("Component/BaseComponent")
local meta = class("GameEvent", BaseComponent)
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function meta:OnLoad()
  self.m_sTagName = self.m_target:getName() .. getIncID()
  self.m_mEventHandler = {}
  self:bindFunction("addEventListener")
  self:bindFunction("broadcastEvent")
  self:bindFunction("removeEventListener")
  self:bindFunction("clearEventListener")
end

function meta:OnDestroy()
  self:clearEventListener()
end

function meta:addEventListener(eventName, listener)
  local eventId = EventDefine[eventName]
  if eventId == nil then
    return nil
  end
  local handlerId = EventCenter.AddListener(eventId, listener)
  if handlerId then
    if self.m_mEventHandler[eventId] == nil then
      self.m_mEventHandler[eventId] = {}
    end
    table.insert(self.m_mEventHandler[eventId], handlerId)
  end
  return handlerId
end

function meta:broadcastEvent(eventName, ...)
  EventCenter.Broadcast(EventDefine[eventName], ...)
end

function meta:removeEventListener(eventName, handlerId)
  local eventId = EventDefine[eventName]
  if eventId == nil or self.m_mEventHandler[eventId] == nil then
    return
  end
  local bFind = false
  for _, handlerIdTmp in pairs(self.m_mEventHandler[eventId]) do
    if handlerIdTmp == handlerId then
      bFind = true
      break
    end
  end
  if not bFind then
    return
  end
  EventCenter.RemoveListener(eventId, handlerId)
end

function meta:clearEventListener()
  for eventId, handlerIds in pairs(self.m_mEventHandler) do
    for _, handlerId in pairs(handlerIds) do
      EventCenter.RemoveListener(eventId, handlerId)
    end
  end
  self.m_mEventHandler = {}
end

return meta
