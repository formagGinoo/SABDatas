local UIItemBase = require("UI/Common/UIItemBase")
local RogueBgGridItem = class("RogueBgGridItem", UIItemBase)

function RogueBgGridItem:OnInit()
  self.m_gridPutRogueEquipItem = nil
  self.m_isUnlock = false
  self.m_isEquip = false
  self.m_GridX = nil
  self.m_GridY = nil
end

function RogueBgGridItem:OnFreshData()
  self.m_GridX = self.m_itemData.gridX
  self.m_GridY = self.m_itemData.gridY
  self.m_isUnlock = self.m_itemData.isUnlock
  self:FreshGridStatus()
end

function RogueBgGridItem:FreshGridStatus()
  UILuaHelper.SetActive(self.m_img_nml, self.m_isUnlock)
  UILuaHelper.SetActive(self.m_img_lock, not self.m_isUnlock)
end

function RogueBgGridItem:SetRogueEquipItem(rogueEquipItem)
  self.m_gridPutRogueEquipItem = rogueEquipItem
end

function RogueBgGridItem:GetRogueEquipItem()
  return self.m_gridPutRogueEquipItem
end

function RogueBgGridItem:IsUnLock()
  return self.m_isUnlock
end

function RogueBgGridItem:IsEquip()
  return self.m_gridPutRogueEquipItem ~= nil
end

function RogueBgGridItem:ChangeUnlockStatus(isUnLock)
  self.m_isUnlock = isUnLock
  self:FreshGridStatus()
end

return RogueBgGridItem
