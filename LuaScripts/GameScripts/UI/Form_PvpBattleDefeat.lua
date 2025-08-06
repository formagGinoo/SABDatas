local Form_PvpBattleDefeat = class("Form_PvpBattleDefeat", require("UI/UIFrames/Form_PvpBattleDefeatUI"))
local math_abs = math.abs

function Form_PvpBattleDefeat:SetInitParam(param)
end

function Form_PvpBattleDefeat:AfterInit()
  self.super.AfterInit(self)
  self.m_playerHeadCom = self:createPlayerHead(self.m_mine_head)
  self.m_playerHeadCom:SetStopClkStatus(true)
end

function Form_PvpBattleDefeat:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
  self:FreshData()
  self:FreshUI()
end

function Form_PvpBattleDefeat:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_PvpBattleDefeat:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PvpBattleDefeat:AddEventListeners()
end

function Form_PvpBattleDefeat:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PvpBattleDefeat:ClearData()
end

function Form_PvpBattleDefeat:FreshData()
  local tParam = self.m_csui.m_param
  if not tParam then
    return
  end
  self.m_levelType = tParam.levelType
  self.m_levelSubType = tParam.levelSubType
  self.m_finishErrorCode = tParam.finishErrorCode
end

function Form_PvpBattleDefeat:FreshUI()
  self:FreshMineInfo()
end

function Form_PvpBattleDefeat:FreshMineInfo()
  local cacheRank, cacheScore
  local finishErrorCode = self.m_finishErrorCode
  if finishErrorCode ~= nil and finishErrorCode ~= 0 then
    UILuaHelper.SetActive(self.m_z_txt_endtips, true)
    cacheRank = ArenaManager:GetSeasonRank()
    cacheScore = ArenaManager:GetSeasonPoint()
  else
    UILuaHelper.SetActive(self.m_z_txt_endtips, false)
    cacheRank, cacheScore = ArenaManager:GetOldInfo()
  end
  cacheRank = cacheRank or 0
  cacheScore = cacheScore or 0
  local curRank = ArenaManager:GetSeasonRank()
  local curScore = ArenaManager:GetSeasonPoint()
  local changeRank = cacheRank - curRank
  local changeScore = curScore - cacheScore
  self.m_txt_ranknum_Text.text = curRank
  UILuaHelper.SetActive(self.m_txt_rankcut, changeRank < 0)
  if changeRank < 0 then
    self.m_txt_rankcut_Text.text = math_abs(changeRank)
  end
  self.m_txt_rival_achievement_Text.text = curScore
  UILuaHelper.SetActive(self.m_txt_achievementcut, changeScore < 0)
  if changeScore < 0 then
    self.m_txt_achievementcut_Text.text = math_abs(changeScore)
  end
  self.m_playerHeadCom:SetPlayerHeadInfo(RoleManager:GetMinePlayerInfoTab())
end

function Form_PvpBattleDefeat:OnBtnBgCloseClicked()
  self:CloseForm()
  BattleFlowManager:ExitBattle()
end

function Form_PvpBattleDefeat:OnBtnDataClicked()
  StackFlow:Push(UIDefines.ID_FORM_BATTLECHARACTERDATA)
end

local fullscreen = true
ActiveLuaUI("Form_PvpBattleDefeat", Form_PvpBattleDefeat)
return Form_PvpBattleDefeat
