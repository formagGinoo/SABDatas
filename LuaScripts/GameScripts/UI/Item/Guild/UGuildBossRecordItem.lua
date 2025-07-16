local UIItemBase = require("UI/Common/UIItemBase")
local UGuildBossRecordItem = class("UGuildBossRecordItem", UIItemBase)

function UGuildBossRecordItem:OnInit()
  self.m_playerHeadCom = self:createPlayerHead(self.m_circle_head)
end

function UGuildBossRecordItem:OnFreshData()
  self:FreshUI()
end

function UGuildBossRecordItem:FreshUI()
  if not self.m_itemData then
    return
  end
  self.m_txt_recordname_Text.text = self.m_itemData.sName or ""
  self.m_txt_damage_Text.text = self.m_itemData.iPower or 0
  self.m_txt_battlenum_Text.text = self.m_itemData.battleCount or 0
  self.m_txt_damage02_Text.text = self.m_itemData.iRealDamage or 0
  local info = GuildManager:GetOwnerGuildMemberDataByUID(self.m_itemData.stRoleId.iUid)
  self.m_playerHeadCom:SetPlayerHeadInfo(info)
end

return UGuildBossRecordItem
