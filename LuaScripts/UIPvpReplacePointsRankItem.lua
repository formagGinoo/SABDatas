local UIItemBase = require("UI/Common/UIItemBase")
local UIPvpReplacePointsRankItem = class("UIPvpReplacePointsRankItem", UIItemBase)
local MaxRankTopNum = 3

function UIPvpReplacePointsRankItem:OnInit()
  self.m_playerHeadCom = self:createPlayerHead(self.m_circle_head_point)
  self.m_playerHeadCom:SetStopClkStatus(true)
end

function UIPvpReplacePointsRankItem:OnFreshData()
  self:FreshRankShow()
end

function UIPvpReplacePointsRankItem:FreshRankShow()
  if not self.m_itemData then
    return
  end
  local rankInfo = self.m_itemData
  local rankNum = rankInfo.iRank
  for i = 1, MaxRankTopNum do
    UILuaHelper.SetActive(self["m_icon_rank" .. i], rankNum == i)
  end
  UILuaHelper.SetActive(self.m_icon_rank4, rankNum > MaxRankTopNum)
  self.m_txt_rank_Text.text = rankNum
  self.m_playerHeadCom:SetPlayerHeadInfo(rankInfo.stRoleSimple)
  self.m_txt_name_Text.text = rankInfo.stRoleSimple.sName
  self.m_txt_power_Text.text = rankInfo.stRoleSimple.mSimpleData[MTTDProto.CmdSimpleDataType_ReplaceArenaDefence] or 0
  self.m_txt_achievement_Text.text = rankInfo.iScore
  self.m_txt_guild_name_Text.text = rankInfo.stRoleSimple.sAlliance ~= "" and rankInfo.stRoleSimple.sAlliance or ConfigManager:GetCommonTextById(20111) or ""
  self.m_z_txt_rank_st1:SetActive(rankNum == 1)
  self.m_z_txt_rank_rd2:SetActive(rankNum == 2)
  self.m_z_txt_rank_nd3:SetActive(rankNum == 3)
  self.m_img_bg_title.gameObject:SetActive(rankNum <= 3)
  if rankNum == 1 then
    self.m_txt_rank_Text.color = RankManager.ColorEnum.first
    self.m_img_bg_title_Image.color = RankManager.ColorEnum.first
  elseif rankNum == 2 then
    self.m_txt_rank_Text.color = RankManager.ColorEnum.second
    self.m_img_bg_title_Image.color = RankManager.ColorEnum.second
  elseif rankNum == 3 then
    self.m_txt_rank_Text.color = RankManager.ColorEnum.third
    self.m_img_bg_title_Image.color = RankManager.ColorEnum.third
  else
    self.m_txt_rank_Text.color = RankManager.ColorEnum.normal
  end
  self.m_img_bg_rank_Image.color = rankNum <= 3 and RankManager.ColorEnum.firstbg or RankManager.ColorEnum.normalbg
end

return UIPvpReplacePointsRankItem
