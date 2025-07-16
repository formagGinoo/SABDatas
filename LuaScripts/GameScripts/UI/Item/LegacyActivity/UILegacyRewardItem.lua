local UIItemBase = require("UI/Common/UIItemBase")
local UILegacyRewardItem = class("UILegacyRewardItem", UIItemBase)
local AnimStr = "LegacyActivity_item_in"

function UILegacyRewardItem:OnInit()
  self.m_itemIcon = self:createCommonItem(self.m_itemTemplateCache:GameObject("c_common_item"))
  self.m_itemIcon:SetItemIconClickCB(function()
    self:OnItemClk()
  end)
  self.m_showItemData = nil
end

function UILegacyRewardItem:OnFreshData()
  self.m_showItemData = self.m_itemData
  self.m_itemIcon:SetItemInfo(self.m_showItemData.itemData)
  self.m_itemIcon:SetItemHaveGetActive(self.m_showItemData.isHaveGet)
end

function UILegacyRewardItem:OnItemClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon)
  end
end

function UILegacyRewardItem:PlayAnim()
  UILuaHelper.PlayAnimationByName(self.m_itemIcon, AnimStr)
end

return UILegacyRewardItem
