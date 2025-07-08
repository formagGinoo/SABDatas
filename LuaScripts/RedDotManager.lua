local BaseManager = require("Manager/Base/BaseManager")
local RedDotManager = class("RedDotManager", BaseManager)
local ModuleDetail = RedDotDefine.ModuleDetail
local RedTreeNode = require("Manager/RedDotSystem/RedTreeNode")
local RedDotItem = require("Manager/RedDotSystem/RedDotItem")

function RedDotManager:OnCreate()
  self:AddEventListeners()
  self.m_redDotMap = {}
  self:InitTree()
end

function RedDotManager:OnUpdate(dt)
end

function RedDotManager:InitTree()
  for key, moduleType in pairs(RedDotDefine.ModuleType) do
    local redTreeNode = RedTreeNode.new(moduleType)
    self.m_redDotMap[moduleType] = redTreeNode
  end
  for key, node in pairs(self.m_redDotMap) do
    local redDotDetail = ModuleDetail[key]
    local parentKey = redDotDetail.parent
    if parentKey then
      self:_SetTreeNodeParent(parentKey, node)
    end
  end
end

function RedDotManager:_SetTreeNodeParent(parentKey, node)
  local parent = self.m_redDotMap[parentKey]
  if parent then
    parent:AddChild(node)
    node:SetParent(parent)
  end
end

function RedDotManager:_GetTargetNode(moduleType)
  if not self.m_redDotMap then
    return
  end
  return self.m_redDotMap[moduleType]
end

function RedDotManager:GetRedDotCount(moduleType)
  if not moduleType then
    log.error("[红点]GetRedDot没有传入moduleType")
    return
  end
  local node = self:_GetTargetNode(moduleType)
  return node:GetCount()
end

function RedDotManager:OnRedDotUpdate(moduleType, count)
  if not moduleType then
    log.error("[红点]没有传入moduleType", moduleType, count)
    return
  end
  local node = self:_GetTargetNode(moduleType)
  if node then
    node:OnRedDotUpdate(count)
  end
end

function RedDotManager:AddEventListeners()
  self:addEventListener("eGameEvent_RedDot_ChangeCount", handler(self, self.OnRedDotCountChangeEvent))
end

function RedDotManager:OnRedDotCountChangeEvent(param)
  if not param then
    return
  end
  self:OnRedDotUpdate(param.redDotKey, param.count)
end

function RedDotManager:RegisterRedDotItem(redDotTrans, redDotType, param)
  if not redDotTrans then
    return
  end
  local redDotItem = RedDotItem.new(redDotTrans)
  redDotItem:FreshData(redDotType, param)
  return redDotItem
end

function RedDotManager:UnRegisterRedDotItem(redDotItem)
  if not redDotItem then
    return
  end
  redDotItem:dispose()
end

return RedDotManager
