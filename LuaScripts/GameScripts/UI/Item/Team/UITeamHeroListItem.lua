local UIItemBase = require("UI/Common/UIItemBase")
local UITeamHeroListItem = class("UITeamHeroListItem", UIItemBase)

function UITeamHeroListItem:OnInit()
  self.m_HeroIcon = self:createHeroTeamIcon(self.m_itemRootObj)
  self.m_HeroIcon:SetHeroIconClickCB(function()
    self:OnHeroItemClick()
  end)
end

function UITeamHeroListItem:OnFreshData()
  local heroData = self.m_itemData
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_HeroIcon:SetHeroData(heroData.serverData, nil, nil, true)
  self.m_HeroIcon:SetTeamCurSelected(heroData.is_cur_hero)
  self.m_HeroIcon:SetTeamSelected(heroData.is_TeamSelected)
end

function UITeamHeroListItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
end

function UITeamHeroListItem:OnChooseItem(flag)
  self.m_isSelected = flag
end

return UITeamHeroListItem
