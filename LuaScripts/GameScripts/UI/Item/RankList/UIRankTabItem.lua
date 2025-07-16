local UIItemBase = require("UI/Common/UIItemBase")
local UIRankTabItem = class("UIRankTabItem", UIItemBase)

function UIRankTabItem:OnInit()
  local itemTrans = self.m_itemRootObj.transform
end

function UIRankTabItem:OnFreshData()
  local data = self.m_itemData
  self.m_tab_charactersel:SetActive(data.isSelect)
  self.m_tab_characternor:SetActive(not data.isSelect)
  self.m_txt_tab_charactersel_Text.text = data.cfg.m_mName
  self.m_txt_tabcharacternor_Text.text = data.cfg.m_mName
  self:RegisterOrUpdateRedDotItem(self.m_redpoint_chara, RedDotDefine.ModuleType.GlobalRankTab, {
    data.cfg.m_RankID
  })
end

function UIRankTabItem:OnBtntabcharacterClicked()
  if self.m_itemInitData and self.m_itemInitData.itemClkBackFun then
    self.m_itemInitData.itemClkBackFun(self.m_itemIndex - 1, self.m_itemRootObj, self.m_itemIcon)
  end
end

return UIRankTabItem
