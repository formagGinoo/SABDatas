local UIItemBase = require("UI/Common/UIItemBase")
local UHuntingRaidRewardTabItem = class("UHuntingRaidRewardTabItem", UIItemBase)

function UHuntingRaidRewardTabItem:OnInit()
end

function UHuntingRaidRewardTabItem:OnFreshData()
  self:FreshUI()
end

function UHuntingRaidRewardTabItem:FreshUI()
  if not self.m_itemData then
    return
  end
  self.m_tab_challengesel:SetActive(self.m_itemData.isSelect)
  self.m_tab_challengenor:SetActive(not self.m_itemData.isSelect)
  self.m_txt_charactersel_Text.text = tostring(self.m_itemData.title)
  self.m_txt_challengenor_Text.text = tostring(self.m_itemData.title)
  self.m_redpoint_chara:SetActive(table.getn(self.m_itemData.canReceiveIds) > 0)
  self.m_txt_numsel_Text.text = tostring(GlobalConfig.RomaSymbols[self.m_itemData.index])
  self.m_txt_numnor_Text.text = tostring(GlobalConfig.RomaSymbols[self.m_itemData.index])
end

return UHuntingRaidRewardTabItem
