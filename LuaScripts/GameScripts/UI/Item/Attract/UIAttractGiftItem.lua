local UIItemBase = require("UI/Common/UIItemBase")
local UIAttractGiftItem = class("UIAttractGiftItem", UIItemBase)

function UIAttractGiftItem:OnInit()
  self.m_itemIcon = self:createCommonItem(self.m_itemRootObj)
  self.m_itemIcon:SetItemIconClickCB(function()
    self:OnItemClk()
  end)
  self.m_itemIcon:SetItemDelClickCB(function()
    self:OnItemDelBtnClk()
  end)
  self.m_itemIcon:SetItemIconLongPress(handler(self, self.OnItemLongClk))
end

function UIAttractGiftItem:OnFreshData()
  self.m_itemIcon:SetItemInfo(self.m_itemData)
  if self.m_itemData.isSameCamp then
    self.m_itemIcon:SetEquipTypeEffect(true)
  else
    self.m_itemIcon:SetEquipTypeEffect(false)
  end
  if self.m_itemData.select_num then
    self:SetUpGradeNum(self.m_itemData.select_num)
  end
end

function UIAttractGiftItem:OnChooseItem(flag)
  self.m_itemData.is_selected = flag
  self.m_itemIcon:SetSelected(flag)
end

function UIAttractGiftItem:SetUpGradeNum(num)
  self.m_itemIcon:SetUpGradeNum(num)
end

function UIAttractGiftItem:ShowHeroIcon(flag)
  self.m_itemIcon:ShowHeroIcon(flag)
end

function UIAttractGiftItem:OnItemClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon)
  end
  if self.m_longPress then
    self.m_longPress:LongClick(true)
  end
end

function UIAttractGiftItem:OnItemDelBtnClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemDelClkBackFun then
    self.m_itemInitData.itemDelClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon)
  end
end

function UIAttractGiftItem:OnItemLongClk(itemId)
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemLongClkBackFun then
    self.m_itemInitData.itemLongClkBackFun(itemId)
  end
end

return UIAttractGiftItem
