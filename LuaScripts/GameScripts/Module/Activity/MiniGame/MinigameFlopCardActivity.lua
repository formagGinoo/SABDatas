local BaseActivity = require("Base/BaseActivity")
local MinigameFlopCardActivity = class("MinigameFlopCardActivity", BaseActivity)
local levelTb = ConfigManager:GetConfigInsByName("MiniGameFlopLevelInfo")
local MiniGameFlopClueRewardsIns = ConfigManager:GetConfigInsByName("MiniGameFlopClueRewards")

function MinigameFlopCardActivity.getActivityType(_)
  return MTTD.ActivityType_MiniGame
end

function MinigameFlopCardActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgMiniGame
end

function MinigameFlopCardActivity.getStatusProto(_)
  return MTTDProto.CmdActMiniGame_Status
end

function MinigameFlopCardActivity:RequestPassLevelCS(iLevelId, iScore, isGetedClue)
  local reqMsg = MTTDProto.Cmd_Act_MiniGame_PassLevel_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iLevelId = iLevelId
  reqMsg.iScore = iScore
  self.isGetedClue = isGetedClue
  RPCS():Act_MiniGame_PassLevel(reqMsg, handler(self, self.RequestPassLevelSC))
end

function MinigameFlopCardActivity:RequestPassLevelSC(data)
  local iActivityId = data.iActivityId
  local iLevelId = data.iLevelId
  local iScore = data.iScore
  local stLevel = data.stLevel
  local vReward = data.vReward
  local isGetClue = false
  if stLevel.iClueTime ~= 0 then
    isGetClue = true
    if utils.isNull(self.m_lvStatusData[iLevelId]) then
      self.m_lvStatusData[iLevelId] = {}
      self.m_lvStatusData[iLevelId].iClueTime = TimeUtil:GetServerTimeS()
      self.m_lvStatusData[iLevelId].iLevelId = iLevelId
      self.m_lvStatusData[iLevelId].iScore = iScore
    else
      self.m_lvStatusData[iLevelId].iClueTime = TimeUtil:GetServerTimeS()
      self.m_lvStatusData[iLevelId].iLevelId = iLevelId
      self.m_lvStatusData[iLevelId].iScore = iScore
    end
  elseif utils.isNull(self.m_lvStatusData[iLevelId]) then
    self.m_lvStatusData[iLevelId] = {}
    self.m_lvStatusData[iLevelId].iClueTime = 0
    self.m_lvStatusData[iLevelId].iLevelId = iLevelId
    self.m_lvStatusData[iLevelId].iScore = iScore
  else
    self.m_lvStatusData[iLevelId].iClueTime = 0
    self.m_lvStatusData[iLevelId].iLevelId = iLevelId
    self.m_lvStatusData[iLevelId].iScore = iScore
  end
  self:FreshReadyClueList()
  self:broadcastEvent("eGameEvent_Level_MinigameFinish", isGetClue, iLevelId)
  StackFlow:Push(UIDefines.ID_FORM_ACTIVITY110_WARMUP_VICTORY, {
    gameWin = true,
    LevelId = iLevelId,
    step = iScore,
    vReward = vReward,
    isGetClue = isGetClue,
    isGetedClue = self.isGetedClue
  })
end

function MinigameFlopCardActivity:RequestGroupRewardCS(iTaskIdGroup)
  local reqMsg = MTTDProto.Cmd_Act_MiniGame_TakeGroupReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.mTakeGroupId = iTaskIdGroup
  RPCS():Act_MiniGame_TakeGroupReward(reqMsg, handler(self, self.RequestGroupRewardSC))
end

function MinigameFlopCardActivity:RequestGroupRewardSC(data)
  local param = {
    actId = data.iActivityId,
    reward = data.vReward
  }
  self.m_stateTaskReward = data.mTakenGroup
  self:broadcastEvent("eGameEvent_Activity_MiniGameTaskGetReward", param)
end

function MinigameFlopCardActivity:OnResetSdpConfig()
  self.m_GameLevel = {}
  if self.m_stSdpConfig then
    for k, v in pairs(self.m_stSdpConfig.stCommonCfg.mGameLevel) do
      self.m_GameLevel[k] = v
    end
  end
  self.m_taskList = self.m_stSdpConfig.stCommonCfg.vClueGroup
end

function MinigameFlopCardActivity:OnResetStatusData()
  self.m_lvStatusData = self.m_stStatusData.mGameLevel
  self.m_stateTaskReward = self.m_stStatusData.mTakenGroup
  self:FreshReadyClueList()
end

function MinigameFlopCardActivity:checkCondition()
  if not MinigameFlopCardActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  return true
end

function MinigameFlopCardActivity:checkShowRed()
  local curServerDate = TimeUtil:GetServerDate(TimeUtil:GetServerTimeS())
  local timeStr = curServerDate.year .. curServerDate.month .. curServerDate.day
  self.lastRdDate = LocalDataManager:GetStringSimple("Activity_FlopCard_DayilyRedpointDt", "")
  if self.lastRdDate ~= timeStr and not self:AllTaskIsFinish() then
    return true
  end
  for k, v in pairs(self.m_GameLevel) do
    local levelCfg = levelTb:GetValue_ByLevelID(k)
    local cur_time = TimeUtil:GetServerTimeS()
    local unlockc1 = cur_time >= v.iOpenTime and cur_time <= v.iCloseTime
    local unlockc2 = false
    if levelCfg.m_OrderLevel == 0 then
      unlockc2 = true
    elseif self.m_lvStatusData[levelCfg.m_OrderLevel] ~= nil then
      unlockc2 = true
    end
    local unlock3 = LocalDataManager:GetIntSimple("Activity_FlopCard_lvRedpoint" .. k, 0) == 0
    local unlock = unlockc1 and unlockc2 and unlock3
    if unlock then
      return true
    end
  end
  if self:GetPendingRewardTasks() then
    return true
  end
  return false
end

function MinigameFlopCardActivity:GetClueGroupTaskList()
  return self.m_taskList
end

function MinigameFlopCardActivity:IsGroupFinished(groupId)
  for id, value in pairs(self.m_readyClueIdList) do
    if value == groupId then
      return true
    end
  end
  return false
end

function MinigameFlopCardActivity:FreshReadyClueList()
  self.m_readyClueIdList = {}
  for id, value in pairs(self.m_lvStatusData) do
    if value.iClueTime ~= 0 then
      local cfg = levelTb:GetValue_ByLevelID(id)
      self.m_readyClueIdList[#self.m_readyClueIdList + 1] = cfg.m_Clue
    end
  end
end

function MinigameFlopCardActivity:IsRewardClaimed(taskId)
  return self.m_stateTaskReward[taskId] ~= nil
end

function MinigameFlopCardActivity:AllTaskIsFinish()
  for _, taskId in pairs(self.m_taskList) do
    if not self:IsGroupFinished(taskId) then
      return false
    end
  end
  return true
end

function MinigameFlopCardActivity:GetPendingRewardTasks()
  local pendingTasks = {}
  local rewardCount = 0
  for _, taskId in pairs(self.m_taskList) do
    if self:IsTaskPendingReward(taskId) then
      pendingTasks[taskId] = true
      rewardCount = rewardCount + 1
    end
  end
  return 0 < rewardCount, pendingTasks
end

function MinigameFlopCardActivity:IsTaskPendingReward(taskId)
  if self:IsRewardClaimed(taskId) then
    return false
  end
  local taskCfg = MiniGameFlopClueRewardsIns:GetValue_ByGroupID(taskId)
  local clueGroupIds = utils.changeCSArrayToLuaTable(taskCfg.m_ClueID)
  local completedCount = 0
  local totalGroups = #clueGroupIds
  for _, clueGroupId in pairs(clueGroupIds) do
    if self:IsGroupFinished(clueGroupId) then
      completedCount = completedCount + 1
    end
  end
  return completedCount == totalGroups
end

function MinigameFlopCardActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_MinigameFlopCardActivity
end

return MinigameFlopCardActivity
