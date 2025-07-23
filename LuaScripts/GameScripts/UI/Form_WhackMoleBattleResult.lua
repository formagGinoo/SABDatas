local Form_WhackMoleBattleResult = class("Form_WhackMoleBattleResult", require("UI/UIFrames/Form_WhackMoleBattleResultUI"))
local VictoryAnimationName = "whackmoleresult_victory_in"
local DefeatAnimationName = "whackmoleresult_defeat_in"
local STATE_HIDE_ALL = 0
local STATE_VICTORY = 1
local STATE_DEFEAT = 2

function Form_WhackMoleBattleResult:SetInitParam(param)
end

function Form_WhackMoleBattleResult:AfterInit()
  self.super.AfterInit(self)
end

function Form_WhackMoleBattleResult:OnActive()
  self.super.OnActive(self)
  if self.m_csui.m_param then
    self.m_battleResult = self.m_csui.m_param
    self.m_csui.m_param = nil
  end
  self.isProhibitClick = true
  self:FreshData()
end

function Form_WhackMoleBattleResult:FreshData()
  if self.m_battleResult then
    local curLevelCfg = HeroActivityManager:GetActWhackMoleInfoCfgByIDAndLevelId(self.m_battleResult.curSubActId, self.m_battleResult.curLevelId)
    local isWin = self.m_battleResult.isWin or false
    local isReplay = false
    self.m_miniGameServerData = HeroActivityManager:GetHeroActData(self.m_battleResult.iActId).server_data.stMiniGame
    if isWin then
      CS.GlobalManager.Instance:TriggerWwiseBGMState(312)
      if self.m_miniGameServerData.mGameStat[self.m_battleResult.curLevelId] ~= 1 or curLevelCfg.m_Mode == HeroActivityManager.WhackMoleLevelType.InfinityType then
        HeroActivityManager:ReqHeroActMiniGameFinishCS(self.m_battleResult.iActId, self.m_battleResult.curSubActId, self.m_battleResult.curLevelId, self.m_battleResult.curScore)
      else
        isReplay = true
      end
    else
      CS.GlobalManager.Instance:TriggerWwiseBGMState(311)
    end
    UILuaHelper.SetActive(self.m_pnl_task, false)
    UILuaHelper.SetActive(self.m_VictoryPanel, isWin)
    UILuaHelper.SetActive(self.m_DefeatPanel, not isWin)
    if curLevelCfg.m_Mode == HeroActivityManager.WhackMoleLevelType.InfinityType then
      self:ShowScoreByType(1)
    elseif curLevelCfg then
      if not isWin then
        if curLevelCfg.m_Mode == HeroActivityManager.WhackMoleLevelType.BossType then
          self:ShowScoreByType(1)
        else
          self:ShowScoreByType(2, curLevelCfg.m_VictoryCondition)
        end
      else
        self:ShowScoreByType(0)
      end
    end
    self:ReSetTimer()
    local obj = isWin and self.m_VictoryPanel or self.m_DefeatPanel
    local animationName = isWin and VictoryAnimationName or DefeatAnimationName
    local animationLength = UILuaHelper.GetAnimationLengthByName(obj, animationName)
    self.m_animaTimer = TimeService:SetTimer(animationLength, 1, function()
      if isWin then
        local canShowTask = false
        local m_cfgList, _ = HeroActivityManager:GetActTaskCfgByActivitySubID(HeroActivityManager:GetSubFuncID(self.m_battleResult.iActId, HeroActivityManager.SubActTypeEnum.GameTask))
        local taskDataList = self:GetActTaskData(self.m_battleResult.iActId, m_cfgList)
        local curTaskData = taskDataList[self.m_battleResult.curLevelId]
        if curLevelCfg.m_Mode == HeroActivityManager.WhackMoleLevelType.InfinityType then
          if self.m_battleResult.curScore >= curTaskData.cfg.m_ObjectiveCount then
            canShowTask = true
          end
        elseif not isReplay then
          canShowTask = true
        end
        if canShowTask then
          UILuaHelper.SetActive(self.m_pnl_task, true)
          self.m_txt_task_Text.text = curTaskData.cfg.m_mTaskName
        end
      end
      self.isProhibitClick = false
    end)
  end
end

function Form_WhackMoleBattleResult:GetActTaskData(activeId, cfgList)
  local cfgDataList = {}
  if cfgList then
    for _, v in ipairs(cfgList) do
      local serverData = HeroActivityManager:GetActTaskServerDataById(activeId, v.m_UID)
      if serverData then
        local preTaskState = HeroActivityManager:CheckTaskStateByTaskId(activeId, v.m_PreTask)
        if preTaskState == TaskManager.TaskState.Completed and (serverData.iState ~= TaskManager.TaskState.Completed or serverData.iState == TaskManager.TaskState.Completed and v.m_Invisible ~= 1) then
          cfgDataList[#cfgDataList + 1] = {
            cfg = v,
            serverData = serverData,
            activeId = activeId
          }
        end
      end
    end
  end
  return cfgDataList
end

function Form_WhackMoleBattleResult:ShowScoreByType(type, victoryConditio)
  local scoreText = tostring(self.m_battleResult.curScore)
  local conditionText = tostring(victoryConditio)
  local uiStates = {
    [STATE_HIDE_ALL] = {pnl_score = false, victoryContent = false},
    [STATE_VICTORY] = {
      victoryContentText = scoreText,
      pnl_score = false,
      victoryContent = true
    },
    [STATE_DEFEAT] = {
      defeatScore = scoreText,
      defeatScore1 = conditionText,
      pnl_score = true,
      victoryContent = false
    }
  }
  local state = uiStates[type] or uiStates.default
  if state.victoryContentText then
    self.m_txt_victoryContent_Text.text = state.victoryContentText
  end
  if state.defeatScore then
    self.m_txt_defeatScore_Text.text = state.defeatScore
    self.m_txt_defeatScore1_Text.text = state.defeatScore1
  end
  UILuaHelper.SetActive(self.m_pnl_score, state.pnl_score)
  UILuaHelper.SetActive(self.m_txt_victoryContent, state.victoryContent)
  UILuaHelper.SetActive(self.m_z_txt_scrorewin, state.victoryContent)
end

function Form_WhackMoleBattleResult:ReSetTimer()
  if self.m_animaTimer then
    TimeService:KillTimer(self.m_animaTimer)
    self.m_animaTimer = nil
  end
end

function Form_WhackMoleBattleResult:OnInactive()
  self:ReSetTimer()
  if self.m_battleResult and self.m_battleResult.callback then
    self.m_battleResult.callback()
    self.m_battleResult.callback = nil
  end
end

function Form_WhackMoleBattleResult:OnBtnCloseClicked()
  if not self.isProhibitClick then
    self:CloseForm()
  end
end

local fullscreen = true
ActiveLuaUI("Form_WhackMoleBattleResult", Form_WhackMoleBattleResult)
return Form_WhackMoleBattleResult
