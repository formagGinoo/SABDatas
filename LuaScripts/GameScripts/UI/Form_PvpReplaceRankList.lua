local Form_PvpReplaceRankList = class("Form_PvpReplaceRankList", require("UI/UIFrames/Form_PvpReplaceRankListUI"))
local RankType = RankManager.RankType
local RankTabType = {Grade = 1, Score = 2}
local MaxRankTopNum = 4
local BattleTeamNum = PvpReplaceManager.BattleTeamNum

function Form_PvpReplaceRankList:SetInitParam(param)
end

function Form_PvpReplaceRankList:AfterInit()
  self.super.AfterInit(self)
  self.TabCfg = {
    [RankTabType.Grade] = {
      selectNode = self.m_img_sel1,
      unSelectNode = self.m_z_txt_nml1,
      panelNode = self.m_pnl_battle_rank
    },
    [RankTabType.Score] = {
      selectNode = self.m_img_sel2,
      unSelectNode = self.m_z_txt_nml2,
      panelNode = self.m_pnl_points_rank
    }
  }
  self.m_playerHeadBattleCom = self:createPlayerHead(self.m_mine_head_battle)
  self.m_playerHeadBattleCom:SetStopClkStatus(true)
  self.m_playerHeadPointCom = self:createPlayerHead(self.m_mine_head_point)
  self.m_playerHeadPointCom:SetStopClkStatus(true)
  self.m_luaBattleRankGrid = self:CreateInfinityGrid(self.m_scrollView2_InfinityGrid, "PvpReplace/UIPvpReplaceBattleRankItem", nil)
  self.m_luaPointRankGrid = self:CreateInfinityGrid(self.m_scrollView_InfinityGrid, "PvpReplace/UIPvpReplacePointsRankItem", nil)
  self.m_battleRankList = nil
  self.m_battleMineInfo = nil
  self.m_pointRankList = nil
  self.m_pointMineInfo = nil
  self.m_curRankTabType = RankTabType.Grade
  self.m_backFun = nil
end

function Form_PvpReplaceRankList:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpReplaceRankList:OnInactive()
  self.super.OnInactive(self)
  self:ClearCacheData()
  self:RemoveAllEventListeners()
end

function Form_PvpReplaceRankList:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpReplaceRankList:FreshData()
  local tParam = self.m_csui.m_param
  if tParam then
    self.m_backFun = tParam.backFun
    self.m_csui.m_param = nil
  end
  self.m_battleRankList = RankManager:GetRankDataListBySystemId(RankType.ReplacePVPGrade) or {}
  self.m_battleMineInfo = RankManager:GetOwnerRankDataListBySystemId(RankType.ReplacePVPGrade)
  self.m_pointRankList = RankManager:GetRankDataListBySystemId(RankType.ReplacePVPScore) or {}
  self.m_pointMineInfo = RankManager:GetOwnerRankDataListBySystemId(RankType.ReplacePVPScore)
end

function Form_PvpReplaceRankList:ClearCacheData()
end

function Form_PvpReplaceRankList:GetTotalPowerNum()
  local totalPowerNum = 0
  for i = 1, BattleTeamNum do
    local levelSubType = PvpReplaceManager.LevelSubType["ReplaceArenaSubType_Defence_" .. i]
    local tempFormData = HeroManager:GetFormDataByLevelTypeAndSubType(PvpReplaceManager.LevelType.ReplacePVP, levelSubType)
    if tempFormData then
      totalPowerNum = totalPowerNum + (tempFormData.iPower or 0)
    end
  end
  return totalPowerNum
end

function Form_PvpReplaceRankList:AddEventListeners()
end

function Form_PvpReplaceRankList:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpReplaceRankList:FreshUI()
  self:FreshRankListShow()
  self:FreshRankMineInfoShow()
  self:ChangeFreshRankShow(RankTabType.Grade)
end

function Form_PvpReplaceRankList:FreshRankListShow()
  if self.m_battleRankList then
    self.m_luaBattleRankGrid:ShowItemList(self.m_battleRankList)
  end
  if self.m_pointRankList then
    self.m_luaPointRankGrid:ShowItemList(self.m_pointRankList)
  end
end

function Form_PvpReplaceRankList:FreshRankMineInfoShow()
  local roleLv = RoleManager:GetLevel()
  local roleName = RoleManager:GetName()
  local allianceName = RoleManager:GetAllianceName()
  if self.m_battleMineInfo then
    local mineRankNum = self.m_battleMineInfo.iMyRank
    for i = 1, MaxRankTopNum do
      UILuaHelper.SetActive(self["m_icon_rank_battle_mine" .. i], mineRankNum == i)
    end
    self.m_txt_rank_battle_mine_Text.text = mineRankNum
    self.m_playerHeadBattleCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
    self.m_txt_name_battle_mine_Text.text = roleName
    self.m_txt_guild_name_battle_mine_Text.text = allianceName
    self.m_txt_power_battle_mine_Text.text = self:GetTotalPowerNum()
    local rankNum = PvpReplaceManager:GetSeasonRank() or 0
    local rankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(rankNum, PvpReplaceManager:GetSeasonArenPlay() or 0)
    if rankCfg then
      self.m_txt_sliver_name_battle_mine_Text.text = rankCfg.m_mName
      UILuaHelper.SetAtlasSprite(self.m_icon_silver_battle_mine_Image, rankCfg.m_RankIcon)
    end
    self.m_z_txt_rank2_ownst1:SetActive(mineRankNum == 1)
    self.m_z_txt_rank2_ownnd2:SetActive(mineRankNum == 2)
    self.m_z_txt_rank2_ownrd3:SetActive(mineRankNum == 3)
    self.m_img_bg_titelown2.gameObject:SetActive(mineRankNum <= 3)
    if mineRankNum == 1 then
      self.m_txt_rank_battle_mine_Text.color = RankManager.ColorEnum.first
      self.m_img_bg_titelown2_Image.color = RankManager.ColorEnum.first
    elseif mineRankNum == 2 then
      self.m_txt_rank_battle_mine_Text.color = RankManager.ColorEnum.second
      self.m_img_bg_titelown2_Image.color = RankManager.ColorEnum.second
    elseif mineRankNum == 3 then
      self.m_txt_rank_battle_mine_Text.color = RankManager.ColorEnum.third
      self.m_img_bg_titelown2_Image.color = RankManager.ColorEnum.third
    else
      self.m_txt_rank_battle_mine_Text.color = RankManager.ColorEnum.normal
    end
    self.m_icon_rank_battle_mine5:SetActive(false)
    self.m_pnl_rankingmine2:SetActive(true)
    self.m_z_txt_norank2:SetActive(false)
  else
    for i = 1, MaxRankTopNum do
      UILuaHelper.SetActive(self["m_icon_rank_battle_mine" .. i], false)
    end
    self.m_pnl_rankingmine2:SetActive(false)
    self.m_icon_rank_battle_mine5:SetActive(true)
    self.m_z_txt_norank2:SetActive(true)
  end
  if self.m_pointMineInfo then
    local mineRankNum = self.m_pointMineInfo.iMyRank
    for i = 1, MaxRankTopNum do
      UILuaHelper.SetActive(self["m_icon_rank_points_mine" .. i], mineRankNum == i)
    end
    self.m_z_txt_rank_ownst1:SetActive(mineRankNum == 1)
    self.m_z_txt_rank_ownnd2:SetActive(mineRankNum == 2)
    self.m_z_txt_rank_ownrd3:SetActive(mineRankNum == 3)
    self.m_img_bg_titelown.gameObject:SetActive(mineRankNum <= 3 and mineRankNum ~= 0)
    if mineRankNum == 1 then
      self.m_txt_rank_points_mine_Text.color = RankManager.ColorEnum.first
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.first
    elseif mineRankNum == 2 then
      self.m_txt_rank_points_mine_Text.color = RankManager.ColorEnum.second
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.second
    elseif mineRankNum == 3 then
      self.m_txt_rank_points_mine_Text.color = RankManager.ColorEnum.third
      self.m_img_bg_titelown_Image.color = RankManager.ColorEnum.third
    else
      self.m_txt_rank_points_mine_Text.color = RankManager.ColorEnum.normal
    end
    self.m_icon_rank_points_mine5:SetActive(false)
    self.m_pnl_rankingmine:SetActive(true)
    self.m_z_txt_norank:SetActive(mineRankNum == 0)
    self.m_txt_rank_points_mine_Text.text = mineRankNum == 0 and "" or mineRankNum
    self.m_playerHeadPointCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
    self.m_txt_name_points_mine_Text.text = roleName
    self.m_txt_guild_name_points_mine_Text.text = allianceName
    self.m_txt_power_points_mine_Text.text = self:GetTotalPowerNum()
    self.m_txt_achievement_points_mine_Text.text = self.m_pointMineInfo.iMyScore
  else
    for i = 1, MaxRankTopNum do
      UILuaHelper.SetActive(self["m_icon_rank_points_mine" .. i], false)
    end
    self.m_icon_rank_points_mine5:SetActive(true)
    self.m_pnl_rankingmine:SetActive(false)
    self.m_z_txt_norank:SetActive(true)
  end
end

function Form_PvpReplaceRankList:ChangeFreshRankShow(rankTabType)
  if self.m_curRankTabType then
    local lastNode = self.TabCfg[self.m_curRankTabType]
    if lastNode then
      UILuaHelper.SetActive(lastNode.selectNode, false)
      UILuaHelper.SetActive(lastNode.unSelectNode, true)
      UILuaHelper.SetActive(lastNode.panelNode, false)
    end
  end
  local curNode = self.TabCfg[rankTabType]
  if curNode then
    UILuaHelper.SetActive(curNode.selectNode, true)
    UILuaHelper.SetActive(curNode.unSelectNode, false)
    UILuaHelper.SetActive(curNode.panelNode, true)
  end
  self.m_curRankTabType = rankTabType
end

function Form_PvpReplaceRankList:OnBtnCloseClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceRankList:OnBtnReturnClicked()
  if self.m_backFun ~= nil then
    self.m_backFun()
  end
  self:CloseForm()
end

function Form_PvpReplaceRankList:OnTab1Clicked()
  self:OnTabClk(RankTabType.Grade)
end

function Form_PvpReplaceRankList:OnTab2Clicked()
  self:OnTabClk(RankTabType.Score)
end

function Form_PvpReplaceRankList:OnTabClk(rewardType)
  if not rewardType then
    return
  end
  if self.m_curRewardType == rewardType then
    return
  end
  self:ChangeFreshRankShow(rewardType)
end

function Form_PvpReplaceRankList:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpReplaceRankList", Form_PvpReplaceRankList)
return Form_PvpReplaceRankList
