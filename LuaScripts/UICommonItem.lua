local UIItemBase = require("UI/Common/UIItemBase")
local UICommonItem = class("UICommonItem", UIItemBase)

function UICommonItem:OnInit()
  self.m_itemIcon = self:createCommonItem(self.m_itemTemplateCache:GameObject("c_common_item"))
  self.m_itemIcon:SetItemIconClickCB(function()
    self:OnItemClk()
  end)
  self.m_itemIcon:SetItemDelClickCB(function()
    self:OnItemDelBtnClk()
  end)
end

function UICommonItem:OnFreshData()
  self.m_itemIcon:SetItemInfo(self.m_itemData)
end

function UICommonItem:OnChooseItem(flag)
  self.m_itemData.is_selected = flag
  self.m_itemIcon:SetSelected(flag)
end

function UICommonItem:SetUpGradeNum(num)
  if self.m_itemData.customData then
    self.m_itemData.customData.sel_upgrade_item_num = num
    self.m_itemIcon:SetUpGradeNum(num)
  end
end

function UICommonItem:ShowHeroIcon(flag)
  self.m_itemIcon:ShowHeroIcon(flag)
end

function UICommonItem:OnItemClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon)
  end
end

function UICommonItem:OnItemDelBtnClk()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemDelClkBackFun then
    self.m_itemInitData.itemDelClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon)
  end
end

return UICommonItem
