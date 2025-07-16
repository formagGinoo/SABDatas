local UIItemBase = require("UI/Common/UIItemBase")
local UGuildBossClanRecordTabItem = class("UGuildBossClanRecordTabItem", UIItemBase)

function UGuildBossClanRecordTabItem:OnInit()
end

function UGuildBossClanRecordTabItem:OnFreshData()
  self:FreshUI()
end

function UGuildBossClanRecordTabItem:FreshUI()
  if not self.m_itemData then
    return
  end
  self.m_select:SetActive(self.m_itemData.isSelect)
  self.m_unselect:SetActive(not self.m_itemData.isSelect)
  self.m_txt_select_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(10007), self.m_itemData.day)
  self.m_txt_unselect_Text.text = string.gsubnumberreplace(ConfigManager:GetCommonTextById(10007), self.m_itemData.day)
end

return UGuildBossClanRecordTabItem
