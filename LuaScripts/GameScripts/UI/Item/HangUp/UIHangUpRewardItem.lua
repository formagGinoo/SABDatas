local UIItemBase = require("UI/Common/UIItemBase")
local UIHangUpRewardItem = class("UIHangUpRewardItem", UIItemBase)

function UIHangUpRewardItem:OnInit()
  self.m_itemIcon = self:createItemIcon(self.m_itemTemplateCache:GameObject("c_common_item_big"))
  self.m_itemIcon:SetItemIconClickCB(function()
    self:OnItemClick()
  end)
end

function UIHangUpRewardItem:OnFreshData()
  self.m_itemIcon:SetItemInfo(self.m_itemData[1], self.m_itemData[2])
end

function UIHangUpRewardItem:OnItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
end

return UIHangUpRewardItem
