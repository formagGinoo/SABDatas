local BaseNode = require("Base/BaseNode")
local RedTreeNode = class("RedTreeNode", BaseNode)

function RedTreeNode:ctor(key)
  RedTreeNode.super.ctor(self, key)
  self.m_key = key
  self.m_childCount = 0
  self.m_redCount = 0
  self.m_selfRedCount = 0
  self.m_config = RedDotDefine.ModuleDetail[key]
  self.m_ChildNodes = nil
  self.m_ParentNode = nil
end

function RedTreeNode:GetKey()
  return self.m_key
end

function RedTreeNode:GetCount()
  return self.m_redCount
end

function RedTreeNode:GetChildCount()
  return self.m_childCount
end

function RedTreeNode:SetParent(node)
  self.m_ParentNode = node
end

function RedTreeNode:AddChild(node)
  if not self.m_ChildNodes then
    self.m_ChildNodes = {}
  end
  self.m_childCount = self.m_childCount + 1
  table.insert(self.m_ChildNodes, node)
  node:SetParent(self)
  return self
end

function RedTreeNode:UpdateCount(count)
  if not count then
    count = self.m_selfRedCount
  else
    self.m_selfRedCount = count
  end
  for i = 1, self.m_childCount do
    local childCount = self.m_ChildNodes[i]:GetCount()
    count = count + childCount
  end
  self.m_redCount = count
  self:broadcastEvent("eGameEvent_RedDot_UpdateCount", {
    redDotKey = self.m_key,
    count = count
  })
  return count
end

function RedTreeNode:OnRedDotUpdate(count)
  local oldValue = self.m_redCount
  local newValue = self:UpdateCount(count)
  if oldValue ~= newValue and self.m_ParentNode then
    log.info("[红点]子节点变化，通知父节点：", self.m_ParentNode:GetKey())
    self.m_ParentNode:OnRedDotUpdate()
  end
end

return RedTreeNode
