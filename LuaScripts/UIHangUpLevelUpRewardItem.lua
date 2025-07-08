local UIItemBase = require("UI/Common/UIItemBase")
local UIHangUpLevelUpRewardItem = class("UIHangUpLevelUpRewardItem", UIItemBase)

function UIHangUpLevelUpRewardItem:OnInit()
  self.m_itemIcon = self:createItemIcon(self.m_itemTemplateCache:GameObject("c_common_item_small"))
  self.m_itemIcon:SetItemIconClickCB(function()
    self:OnItemClick()
  end)
end

function UIHangUpLevelUpRewardItem:OnFreshData()
  self.m_itemIcon:SetItemInfo(self.m_itemData[1], self.m_itemData[2])
end

function UIHangUpLevelUpRewardItem:OnItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
end

return UIHangUpLevelUpRewardItem
