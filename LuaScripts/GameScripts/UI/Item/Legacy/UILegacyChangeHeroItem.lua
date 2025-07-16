local UIItemBase = require("UI/Common/UIItemBase")
local UILegacyChangeHeroItem = class("UILegacyChangeHeroItem", UIItemBase)

function UILegacyChangeHeroItem:OnInit()
  if self.m_itemInitData then
    self.m_itemClkBackFun = self.m_itemInitData.itemClkBackFun
  end
  self.m_commonWidget = self:createCommonItem(self.m_herohead.gameObject)
end

function UILegacyChangeHeroItem:OnFreshData()
  local heroData = self.m_itemData
  if not heroData then
    return
  end
  self.m_heroCfg = heroData.characterCfg
  self.m_heroServerData = heroData.serverData
  self:FreshItemUI()
end

function UILegacyChangeHeroItem:FreshItemUI()
  if not self.m_heroServerData then
    return
  end
  local processItemData = ResourceUtil:GetProcessRewardData({
    iID = self.m_heroServerData.iHeroId,
    iNum = 0
  })
  self.m_commonWidget:SetItemInfo(processItemData)
  self:FreshHeroInfo()
end

function UILegacyChangeHeroItem:FreshHeroInfo()
  if not self.m_heroServerData then
    return
  end
  self.m_txt_heroname_Text.text = self.m_heroCfg.m_mName
  self.m_txt_power_Text.text = self.m_heroServerData.iPower
end

function UILegacyChangeHeroItem:OnBtnChangeClicked()
  if self.m_itemClkBackFun then
    self.m_itemClkBackFun(self.m_itemIndex)
  end
end

return UILegacyChangeHeroItem
