local UIItemBase = require("UI/Common/UIItemBase")
local UIPersonalRaidItem = class("UIPersonalRaidItem", UIItemBase)
local MaxRankTopNum = 3

function UIPersonalRaidItem:OnInit()
  self.m_playerHeadCom = self:createPlayerHead(self.m_circle_head2)
end

function UIPersonalRaidItem:OnFreshData()
  self:FreshRankShow()
end

function UIPersonalRaidItem:FreshRankShow()
  if not self.m_itemData then
    return
  end
  local rankInfo = self.m_itemData
  local rankNum = rankInfo.iRank
  for i = 1, MaxRankTopNum do
    UILuaHelper.SetActive(self["m_icon_battle_rank" .. i], rankNum == i)
  end
  self.m_z_txt_rank_st1:SetActive(rankNum == 1)
  self.m_z_txt_rank_rd2:SetActive(rankNum == 2)
  self.m_z_txt_rank_nd3:SetActive(rankNum == 3)
  self.m_icon_battle_rank4:SetActive(4 <= rankNum)
  self.m_txt_rank2_Text.text = rankNum
  self.m_txt_name2_Text.text = rankInfo.stRoleSimple.sName
  self.m_txt_damage_Text.text = rankInfo.iScore
  self.m_txt_power2_Text.text = rankInfo.stRoleSimple.mSimpleData[MTTDProto.CmdSimpleDataType_TopFiveHeroPower] or 0
  self.m_txt_guild_name2_Text.text = rankInfo.stRoleSimple.sAlliance ~= "" and rankInfo.stRoleSimple.sAlliance or ConfigManager:GetCommonTextById(20111) or ""
  self.m_playerHeadCom:SetPlayerHeadInfo(rankInfo.stRoleSimple)
end

function UIPersonalRaidItem:OnBtnchecklistClicked()
  StackPopup:Push(UIDefines.ID_FORM_PERSONALRAIDBATTLEINFO, {
    stTargetId = self.m_itemData.stRoleSimple.stRoleId,
    from_rank = true
  })
end

return UIPersonalRaidItem
