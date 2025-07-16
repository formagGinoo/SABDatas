local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroMiddleListItem = class("UIHeroMiddleListItem", UIItemBase)

function UIHeroMiddleListItem:OnInit()
  self.m_HeroIcon = self:createHeroIcon(self.m_itemRootObj)
  self.m_imgRedDot = self.m_itemTemplateCache:GameObject("c_img_redDot")
  self.m_HeroIcon:SetHeroIconClickCB(function()
    self:OnHeroItemClick()
  end)
end

function UIHeroMiddleListItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_HeroIcon:SetHeroData(self.m_itemData.serverData, StargazingManager:GetDispatchHero(self.m_itemData.serverData.iHeroId))
  self.m_HeroIcon:SetHeroStyleForStargazing()
end

function UIHeroMiddleListItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex, self)
  end
end

function UIHeroMiddleListItem:OnChooseItem(flag)
  self.m_HeroIcon:SetSelected(flag)
end

return UIHeroMiddleListItem
