local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroListGuideItem = class("UIHeroListGuideItem", UIItemBase)

function UIHeroListGuideItem:OnInit()
  self.m_HeroIcon = self:createHeroIcon(self.m_itemRootObj)
  self.m_HeroIcon:SetHeroIconClickCB(function()
    self:OnHeroItemClick()
  end)
  self.m_isSelected = false
end

function UIHeroListGuideItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_HeroIcon:SetHeroData(self.m_itemData.serverData, self.m_isSelected, nil, true)
  self.m_HeroIcon:SetHeroGrey(not self.m_itemData.isHave, self.m_itemInitData.greyMat)
end

function UIHeroListGuideItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
end

function UIHeroListGuideItem:OnChooseItem(flag)
  self.m_isSelected = flag
  self.m_HeroIcon:SetSelected(flag)
end

return UIHeroListGuideItem
