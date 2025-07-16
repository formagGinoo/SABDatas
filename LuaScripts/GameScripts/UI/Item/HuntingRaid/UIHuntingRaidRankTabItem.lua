local UIItemBase = require("UI/Common/UIItemBase")
local UIHuntingRaidRankTabItem = class("UIHuntingRaidRankTabItem", UIItemBase)

function UIHuntingRaidRankTabItem:OnInit()
end

function UIHuntingRaidRankTabItem:OnFreshData()
  self:FreshUI()
end

function UIHuntingRaidRankTabItem:FreshUI()
  if not self.m_itemData then
    return
  end
  self.m_tab_minranksel:SetActive(self.m_itemData.isSelect)
  self.m_tab_minranknor:SetActive(not self.m_itemData.isSelect)
  self.m_txt_tab_num_Text.text = tostring(GlobalConfig.RomaSymbols[self.m_itemData.index])
  self.m_txt_tab_name_Text.text = tostring(self.m_itemData.title)
  self.m_txt_tab_num02_Text.text = tostring(GlobalConfig.RomaSymbols[self.m_itemData.index])
  self.m_txt_tab_name02_Text.text = tostring(self.m_itemData.title)
end

return UIHuntingRaidRankTabItem
