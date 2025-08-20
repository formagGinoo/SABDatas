local UIItemBase = require("UI/Common/UIItemBase")
local UIPvpReplaceBattleRankItem = class("UIPvpReplaceBattleRankItem", UIItemBase)
local MaxRankTopNum = 3

function UIPvpReplaceBattleRankItem:OnInit()
  self.m_playerHeadCom = self:createPlayerHead(self.m_circle_head_battle)
  self.m_playerHeadCom:SetStopClkStatus(true)
end

function UIPvpReplaceBattleRankItem:IsBan()
  if not self.m_itemData then
    return false
  end
  local simpleInfo = self.m_itemData.stRoleSimple
  if not simpleInfo then
    return false
  end
  if simpleInfo.iBanShowType and simpleInfo.iBanShowType > 0 and simpleInfo.iBanEndTime and 0 < simpleInfo.iBanEndTime and simpleInfo.iBanEndTime > TimeUtil:GetServerTimeS() then
    return true
  end
  return false
end

function UIPvpReplaceBattleRankItem:GetPlayerName()
  if not self.m_itemData then
    return
  end
  local simpleInfo = self.m_itemData.stRoleSimple
  if not simpleInfo then
    return
  end
  if self:IsBan() then
    return ConfigManager:GetCommonTextById(20367)
  end
  return simpleInfo.sName
end

function UIPvpReplaceBattleRankItem:OnFreshData()
  self:FreshRankShow()
end

function UIPvpReplaceBattleRankItem:FreshRankShow()
  if not self.m_itemData then
    return
  end
  local rankInfo = self.m_itemData
  local rankNum = rankInfo.iRank
  for i = 1, MaxRankTopNum do
    UILuaHelper.SetActive(self["m_icon_battle_rank" .. i], rankNum == i)
  end
  UILuaHelper.SetActive(self.m_icon_battle_rank4, rankNum > MaxRankTopNum)
  self.m_txt_rank2_Text.text = rankNum
  self.m_playerHeadCom:SetPlayerHeadInfo(rankInfo.stRoleSimple)
  self.m_txt_name2_Text.text = self:GetPlayerName() or ""
  self.m_txt_power2_Text.text = rankInfo.stRoleSimple.mSimpleData[MTTDProto.CmdSimpleDataType_ReplaceArenaDefence] or 0
  self.m_txt_guild_name2_Text.text = rankInfo.stRoleSimple.sAlliance ~= "" and rankInfo.stRoleSimple.sAlliance or ConfigManager:GetCommonTextById(20111) or ""
  local rankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(rankNum, rankInfo.stRoleSimple.iReplaceArenaPlaySeason)
  if rankCfg then
    self.m_txt_sliver_name_Text.text = rankCfg.m_mName
    UILuaHelper.SetAtlasSprite(self.m_icon_silver_Image, rankCfg.m_RankIcon)
  end
  self.m_z_txt_rank2_st1:SetActive(rankNum == 1)
  self.m_z_txt_rank2_rd2:SetActive(rankNum == 2)
  self.m_z_txt_rank2_nd3:SetActive(rankNum == 3)
  self.m_img_bg_title2.gameObject:SetActive(rankNum <= 3)
  if rankNum == 1 then
    self.m_txt_rank2_Text.color = RankManager.ColorEnum.first
    self.m_img_bg_title2_Image.color = RankManager.ColorEnum.first
  elseif rankNum == 2 then
    self.m_txt_rank2_Text.color = RankManager.ColorEnum.second
    self.m_img_bg_title2_Image.color = RankManager.ColorEnum.second
  elseif rankNum == 3 then
    self.m_txt_rank2_Text.color = RankManager.ColorEnum.third
    self.m_img_bg_title2_Image.color = RankManager.ColorEnum.third
  else
    self.m_txt_rank2_Text.color = RankManager.ColorEnum.normal
  end
  self.m_img_bg_rank_Image.color = rankNum <= 3 and RankManager.ColorEnum.firstbg or RankManager.ColorEnum.normalbg
end

return UIPvpReplaceBattleRankItem
