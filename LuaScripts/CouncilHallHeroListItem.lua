local UIItemBase = require("UI/Common/UIItemBase")
local CouncilHallHeroListItem = class("CouncilHallHeroListItem", UIItemBase)

function CouncilHallHeroListItem:OnInit()
  self.m_HeroIcon = self:createHeroIcon(self.m_itemRootObj)
  self.m_HeroIcon:SetHeroIconClickCB(function()
    self:OnHeroItemClick()
  end)
end

function CouncilHallHeroListItem:OnFreshData()
  local heroData = self.m_itemData
  self.m_itemRootObj.name = self.m_itemIndex
  self.m_HeroIcon:SetHeroData(heroData.serverData, nil, nil, true)
  self.m_txt_flowernum_Text.text = heroData.serverData.iAttractRank
  self.m_HeroIcon:SetSelected(heroData.is_CouncilSelected)
end

function CouncilHallHeroListItem:OnHeroItemClick()
  if not self.m_itemIndex then
    return
  end
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj)
  end
  CS.GlobalManager.Instance:TriggerWwiseBGMState(189)
end

return CouncilHallHeroListItem
