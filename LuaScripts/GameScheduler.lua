local BaseComponent = require("Component/BaseComponent")
local meta = class("GameScheduler", BaseComponent)

function meta:OnLoad()
  self.m_vSchedulerHandlerId = {}
  self.m_uiRoot = nil
  self:bindFunction("setTimer")
  self:bindFunction("setTimerOnce")
  self:bindFunction("resetTimer")
  self:bindFunction("killTimer")
end

function meta:setUIRoot(uiRoot)
  self.m_uiRoot = uiRoot
end

function meta:OnDestroy()
  self:killAllTimer()
end

function meta:setTimer(...)
  local iSchedulerHandler = TimeService:SetTimer(...)
  table.insert(self.m_vSchedulerHandlerId, iSchedulerHandler)
  return iSchedulerHandler
end

function meta:resetTimer(iSchedulerHandler)
  TimeService:ResetTimer(iSchedulerHandler)
end

function meta:killTimer(iSchedulerHandler)
  if iSchedulerHandler then
    for iIndex, iSchedulerHandlerTmp in ipairs(self.m_vSchedulerHandlerId) do
      if iSchedulerHandlerTmp == iSchedulerHandler then
        table.remove(self.m_vSchedulerHandlerId, iIndex)
        break
      end
    end
    TimeService:KillTimer(iSchedulerHandler)
  end
end

function meta:killAllTimer()
  for _, iSchedulerHandler in ipairs(self.m_vSchedulerHandlerId) do
    TimeService:KillTimer(iSchedulerHandler)
  end
  self.m_vSchedulerHandlerId = {}
end

return meta
