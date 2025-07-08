local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroListCommonItem = class("UIHeroListCommonItem", UIItemBase)

function UIHeroListCommonItem:OnInit()
  self.m_HeroIcon = self:createHeroIcon(self.m_itemRootObj)
  self.m_HeroIcon:SetHeroIconClickCB(function()
    self:OnHeroItemClick()
  end)
  if self.m_itemInitData and self.m_itemInitData.itemLongPressBackFun then
    self.m_HeroIcon:SetHeroIconLongPressCB(function()
      self:OnHeroItemLongPress()
    end)
  end
end

function UIHeroListCommonItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  local showMoon = false
  if self.m_itemData.isShowMoon == nil then
    showMoon = true
  end
  self.m_HeroIcon:SetHeroData(self.m_itemData.serverData, self.m_itemData.is_selected, self.m_itemData.isHideBreak, showMoon, self.m_itemData.isHideLv)
end

function UIHeroListCommonItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
end

function UIHeroListCommonItem:OnHeroItemLongPress()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemLongPressBackFun then
    self.m_itemInitData.itemLongPressBackFun(self.m_itemIndex - 1)
  end
end

function UIHeroListCommonItem:OnChooseItem(flag)
  self.m_itemData.is_selected = flag
  self.m_HeroIcon:SetSelected(flag)
end

return UIHeroListCommonItem
