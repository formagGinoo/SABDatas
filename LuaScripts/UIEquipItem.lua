local UIItemBase = require("UI/Common/UIItemBase")
local UIEquipItem = class("UIEquipItem", UIItemBase)

function UIEquipItem:OnInit()
  self.m_itemIcon = self:createEquipIcon(self.m_itemTemplateCache:GameObject("c_common_equip"))
  self.m_itemIcon:SetItemIconClickCB(function()
    self:OnEquipItemClk()
  end)
end

function UIEquipItem:OnFreshData()
  self.m_itemIcon:SetEquipInfo(self.m_itemData)
end

function UIEquipItem:OnEquipItemClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon)
  end
end

return UIEquipItem
