local UIItemBase = require("UI/Common/UIItemBase")
local UIHeroListItem = class("UIHeroListItem", UIItemBase)

function UIHeroListItem:OnInit()
  self.m_HeroIcon = self:createHeroIcon(self.m_itemRootObj)
  self.m_imgRedDot = self.m_itemTemplateCache:GameObject("c_img_redDot")
  self.m_HeroIcon:SetHeroIconClickCB(function()
    self:OnHeroItemClick()
  end)
  self.m_isSelected = false
end

function UIHeroListItem:OnFreshData()
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_HeroIcon:SetHeroData(self.m_itemData.serverData, self.m_isSelected, nil, true)
  self:RegisterOrUpdateRedDotItem(self.m_imgRedDot, RedDotDefine.ModuleType.HeroListItem, self.m_itemData.serverData.iHeroId)
end

function UIHeroListItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
end

function UIHeroListItem:OnChooseItem(flag)
  self.m_isSelected = flag
  self.m_HeroIcon:SetSelected(flag)
end

return UIHeroListItem
