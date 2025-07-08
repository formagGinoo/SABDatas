local Form_PvpReplaceBattleDefeat = class("Form_PvpReplaceBattleDefeat", require("UI/UIFrames/Form_PvpReplaceBattleDefeatUI"))

function Form_PvpReplaceBattleDefeat:SetInitParam(param)
end

function Form_PvpReplaceBattleDefeat:AfterInit()
  self.super.AfterInit(self)
  self.m_levelType = nil
  self.m_levelSubType = nil
  self.m_finishErrorCode = nil
  self.m_resultData = nil
  self.m_playerHeadCom = self:createPlayerHead(self.m_mine_head)
  self.m_playerHeadCom:SetStopClkStatus(true)
  self.m_otherPlayerHeadCom = self:createPlayerHead(self.m_other_head)
  self.m_otherPlayerHeadCom:SetStopClkStatus(true)
end

function Form_PvpReplaceBattleDefeat:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpReplaceBattleDefeat:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
  self:ClearData()
end

function Form_PvpReplaceBattleDefeat:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpReplaceBattleDefeat:AddEventListeners()
end

function Form_PvpReplaceBattleDefeat:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpReplaceBattleDefeat:ClearData()
end

function Form_PvpReplaceBattleDefeat:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelType = tParam.levelType
  self.m_levelSubType = tParam.levelSubType
  self.m_finishErrorCode = tParam.finishErrorCode
  self.m_resultData = PvpReplaceManager:GetBattleResultData()
  self.m_csui.m_param = nil
end

function Form_PvpReplaceBattleDefeat:FreshUI()
  self:FreshRoundInfo()
end

function Form_PvpReplaceBattleDefeat:FreshRoundInfo()
  local rankNum = self.m_resultData.iRank
  local oldRankNum = self.m_resultData.iOldRank
  self.m_playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
  local rankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(rankNum)
  if rankCfg then
    UILuaHelper.SetAtlasSprite(self.m_icon_left_Image, rankCfg.m_RankIcon)
    self.m_txt_left_Text.text = rankNum
  end
  local enemyDetail = PvpReplaceManager:GetEnemyDetail()
  if enemyDetail then
    local roleSimpleInfo = enemyDetail.stRoleSimple
    self.m_otherPlayerHeadCom:SetPlayerHeadInfo(roleSimpleInfo)
  end
  local enemyBaseInfo = PvpReplaceManager:GetCurBattleEnemy() or {}
  local showRankNum = self.m_finishErrorCode == MTTD.Error_ReplaceArena_EnemyRankLow and enemyBaseInfo.iRank or oldRankNum
  local enemyRankCfg = PvpReplaceManager:GetReplaceRankCfgByRankNum(showRankNum)
  if enemyRankCfg then
    UILuaHelper.SetAtlasSprite(self.m_icon_right_Image, enemyRankCfg.m_RankIcon)
    self.m_txt_right_Text.text = showRankNum
  end
  for i = 1, PvpReplaceManager.BattleTeamNum do
    local roundResult = self.m_resultData.vResult[i]
    UILuaHelper.SetActive(self["m_btn_round" .. i], roundResult ~= nil)
    if roundResult ~= nil then
      UILuaHelper.SetActive(self["m_img_victory" .. i], roundResult == 1)
      UILuaHelper.SetActive(self["m_img_defeat" .. i], roundResult ~= 1)
    end
  end
end

function Form_PvpReplaceBattleDefeat:OnBtnBgCloseClicked()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_PvpReplaceBattleDefeat:OnBtnround1Clicked()
  self:OnRoundClk(1)
end

function Form_PvpReplaceBattleDefeat:OnBtnround2Clicked()
  self:OnRoundClk(2)
end

function Form_PvpReplaceBattleDefeat:OnBtnround3Clicked()
  self:OnRoundClk(3)
end

function Form_PvpReplaceBattleDefeat:OnRoundClk(index)
  if not index then
    return
  end
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA, index - 1)
end

function Form_PvpReplaceBattleDefeat:IsFullScreen()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PvpReplaceBattleDefeat", Form_PvpReplaceBattleDefeat)
return Form_PvpReplaceBattleDefeat
