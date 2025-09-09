local UIItemBase = require("UI/Common/UIItemBase")
local UICloneMulCommonItem = class("UICloneMulCommonItem", UIItemBase)

function UICloneMulCommonItem:OnInit()
  self.m_itemIcon = self:createCommonItem(self.m_itemRootObj)
  self.m_itemIcon:SetItemIconClickCB(function()
    self:OnItemClk()
  end)
  self.m_itemIcon:SetItemDelClickCB(function()
    self:OnItemDelBtnClk()
  end)
  self.m_itemIcon:SetItemIconLongPress(function()
    self:OnItemLongClk()
  end)
end

function UICloneMulCommonItem:OnFreshData()
  self.m_itemIcon:SetItemInfo(self.m_itemData)
end

function UICloneMulCommonItem:OnChooseItem(flag)
  self.m_itemData.is_selected = flag
  self.m_itemIcon:SetSelected(flag)
end

function UICloneMulCommonItem:SetUpGradeNum(num)
  if self.m_itemData.customData then
    self.m_itemData.customData.sel_upgrade_item_num = num
    self.m_itemIcon:SetUpGradeNum(num)
  end
end

function UICloneMulCommonItem:ShowHeroIcon(flag)
  self.m_itemIcon:ShowHeroIcon(flag)
end

function UICloneMulCommonItem:OnItemClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon, self.m_itemData)
  end
end

function UICloneMulCommonItem:OnItemDelBtnClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemDelClkBackFun then
    self.m_itemInitData.itemDelClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon, self.m_itemData)
  end
end

function UICloneMulCommonItem:OnItemLongClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemLongClkBackFun then
    self.m_itemInitData.itemLongClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon, self.m_itemData)
  end
end

return UICloneMulCommonItem
