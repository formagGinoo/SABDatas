local BaseNode = require("Base/BaseNode")
local RedDotItem = class("RedDotItem", BaseNode)

function RedDotItem:ctor(redDotNode)
  RedDotItem.super.ctor(self, redDotNode)
  self.m_redDotNode = redDotNode
  self.m_isInit = false
  self.count = 0
  self.m_redDotType = nil
  self.m_redDotDetail = nil
  self.m_redDotParam = nil
end

function RedDotItem:OnCreate()
end

function RedDotItem:FreshData(redDotType, param)
  if not redDotType then
    return
  end
  if self.m_isInit then
    self:RemoveAllRedDotEventListeners()
  end
  self.m_redDotType = redDotType
  self.m_redDotDetail = RedDotDefine.ModuleDetail[self.m_redDotType]
  if not self.m_redDotDetail then
    return
  end
  self:AddRedDotEventListeners()
  if self.m_redDotDetail.isParamRedDot then
    self:FreshParamRedDot(param)
  else
    self:FreshTypeRedDot()
  end
  self.m_isInit = true
end

function RedDotItem:AddRedDotEventListeners()
  if not self.m_redDotDetail then
    return
  end
  local eventNameList = self.m_redDotDetail.eventNameList
  if eventNameList == nil then
    self:addEventListener("eGameEvent_RedDot_UpdateCount", handler(self, self.OnRedDotEventUpdateCount))
  else
    for _, eventNameStr in ipairs(eventNameList) do
      self:addEventListener(eventNameStr, handler(self, self.OnRedDotEventUpdateCount))
    end
  end
end

function RedDotItem:RemoveAllRedDotEventListeners()
  self:clearEventListener()
end

function RedDotItem:OnRedDotEventUpdateCount(param)
  if UILuaHelper.IsNull(self.m_redDotNode) then
    log.error("RedDotItem EventTrigger m_redDotNode is Destroy But TriggerEvent" .. self.m_redDotType)
    return
  end
  if not self.m_redDotDetail then
    return
  end
  if self.m_redDotDetail.isParamRedDot then
    self:FreshParamRedDot(self.m_redDotParam)
  elseif param.redDotKey == self.m_redDotType then
    self:FreshTypeRedDot()
  end
end

function RedDotItem:FreshParamRedDot(param)
  if not self.m_redDotDetail then
    return
  end
  if not self.m_redDotDetail.isParamRedDot then
    return
  end
  self.m_redDotParam = param or self.m_redDotParam
  local managerName = self.m_redDotDetail.managerName
  if not managerName or managerName == "" then
    log.error("RedDotItem FreshParamRedDot isParamRedDot 为true 但是没有manager参数")
    return
  end
  local getCountFunName = self.m_redDotDetail.getCountFunName
  if not getCountFunName or getCountFunName == "" then
    log.error("RedDotItem FreshParamRedDot isParamRedDot 为true 但是没有getCountFunName参数")
    return
  end
  local manager = _G[managerName]
  if not manager then
    return
  end
  if not manager[getCountFunName] then
    return
  end
  local countNum = manager[getCountFunName](manager, param)
  if countNum == nil or countNum <= 0 then
    UILuaHelper.SetActive(self.m_redDotNode, false)
  else
    UILuaHelper.SetActive(self.m_redDotNode, true)
  end
end

function RedDotItem:FreshTypeRedDot()
  if not self.m_redDotType then
    return
  end
  local countNum = RedDotManager:GetRedDotCount(self.m_redDotType)
  if countNum == nil or countNum <= 0 then
    UILuaHelper.SetActive(self.m_redDotNode, false)
  else
    UILuaHelper.SetActive(self.m_redDotNode, true)
  end
end

function RedDotItem:GetRedDotType()
  return self.m_redDotType
end

function RedDotItem:GetRedDotTrans()
  return self.m_redDotNode
end

function RedDotItem:dispose()
  RedDotItem.super.dispose(self)
end

function RedDotItem:OnDestroy()
  self:RemoveAllRedDotEventListeners()
  self.m_redDotNode = nil
  self.m_isInit = nil
  self.count = nil
  self.m_redDotType = nil
  self.m_redDotDetail = nil
  self.m_redDotParam = nil
end

return RedDotItem
