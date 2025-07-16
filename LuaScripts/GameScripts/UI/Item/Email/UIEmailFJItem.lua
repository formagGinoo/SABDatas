local UIItemBase = require("UI/Common/UIItemBase")
local UIEmailFJItem = class("UIEmailFJItem", UIItemBase)

function UIEmailFJItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_itemWidget = self:createCommonItem(self.m_itemRootObj)
  self.m_itemWidget:SetItemIconClickCB(handler(self, self.OnEmailFJItemClicked))
end

function UIEmailFJItem:OnFreshData()
  self.m_emailFJItemData = self.m_itemData
  if not self.m_emailFJItemData then
    return
  end
  self:FreshItemUI()
  self:FreshChooseStatus(self.m_emailFJItemData.isChoose)
end

function UIEmailFJItem:FreshItemUI()
  if not self.m_emailFJItemData then
    return
  end
  local iconWidget = self.m_itemWidget
  local processData = ResourceUtil:GetProcessRewardData(self.m_emailFJItemData.itemData)
  iconWidget:SetItemInfo(processData)
end

function UIEmailFJItem:FreshChooseStatus(isChoose)
  if not self.m_itemWidget then
    return
  end
  self.m_itemWidget:SetItemHaveGetActive(isChoose)
end

function UIEmailFJItem:ChangeChooseStatus(isChoose)
  self.m_emailItemData.isChoose = isChoose
  self:FreshChooseStatus(isChoose)
end

function UIEmailFJItem:OnEmailFJItemClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UIEmailFJItem
