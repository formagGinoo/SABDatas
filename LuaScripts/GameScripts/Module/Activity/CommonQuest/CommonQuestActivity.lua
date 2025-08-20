local BaseActivity = require("Base/BaseActivity")
local CommonQuestActivity = class("CommonQuestActivity", BaseActivity)
local iDayMax = 7
local iMaxScoreRewardCount = 5

function CommonQuestActivity.getActivityType(_)
  return MTTD.ActivityType_CommonQuest
end

function CommonQuestActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgCommonQuest
end

function CommonQuestActivity.getStatusProto(_)
  return MTTDProto.CmdActCommonQuest_Status
end

function CommonQuestActivity:OnCreate()
  self.m_vQuest = {}
  self.m_vQuestOver = {}
end

function CommonQuestActivity:OnResetSdpConfig()
  if not self.isListen then
    RPCS():Listen_Push_SetQuestDataBatch(handler(self, self.OnPushSetQuestDataBatch), "CommonQuestActivity" .. self.m_stActivityData.iActivityId)
    self.isListen = true
  end
  self.m_mQuestConfig = {}
  for _, stQuestConfig in pairs(self.m_stSdpConfig.mQuest) do
    self.m_mQuestConfig[stQuestConfig.iId] = stQuestConfig
  end
  self.m_mDailyRewardConfig = {}
  for _, stDailyReward in pairs(self.m_stSdpConfig.mDailyReward) do
    self.m_mDailyRewardConfig[stDailyReward.iOpenDay] = stDailyReward
  end
  self.m_mFinalRewardConfig = {}
  self.iFinalScore = 0
  for iScore, stFinalReward in pairs(self.m_stSdpConfig.mFinalReward) do
    self.m_mFinalRewardConfig[iScore] = stFinalReward
    if iScore > self.iFinalScore then
      self.iFinalScore = iScore
    end
  end
  self.m_UIType = self.m_stSdpConfig.iUiType or 0
  self.m_UpActivityID = self.m_stSdpConfig.iLamiaActId or 0
  iDayMax = #self.m_mDailyRewardConfig
  self:ResetCommonQuestRefreshTime()
end

function CommonQuestActivity:OnResetStatusData()
  if self.m_stStatusData.iBeginTime <= 0 then
    self.m_iDayNum = 1
  else
    self.m_iDayNum = TimeUtil:GetPassedServerDay(self.m_stStatusData.iBeginTime)
  end
  self.m_vQuest = self.m_stStatusData.vQuest
  self.m_vQuestOver = self.m_stStatusData.vOver
end

function CommonQuestActivity:OnPushSetQuestDataBatch(stTaskData, msg)
  local vQuestStatusChanged = {}
  local vQuest = stTaskData.vCmdQuestInfo
  local vQuestOver = {}
  for _, stQuestStatus in pairs(vQuest) do
    if stQuestStatus.iType == self:getID() then
      table.insert(vQuestStatusChanged, stQuestStatus)
      local bHave = false
      for _, stQuestStatusTmp in ipairs(self.m_vQuest) do
        if stQuestStatusTmp.iId == stQuestStatus.iId then
          if stQuestStatus.iState == MTTDProto.QuestState_Over then
            table.insert(vQuestOver, stQuestStatus.iId)
          else
            stQuestStatusTmp.iState = stQuestStatus.iState
            stQuestStatusTmp.vCondStep = stQuestStatus.vCondStep
          end
          bHave = true
          break
        end
      end
      if not bHave then
        table.insert(self.m_vQuest, stQuestStatus)
      end
    end
  end
  for _, iQuestId in pairs(vQuestOver) do
    for i = #self.m_vQuest, 1, -1 do
      local stQuestStatusTmp = self.m_vQuest[i]
      if stQuestStatusTmp.iId == iQuestId then
        table.remove(self.m_vQuest, i)
        table.insert(self.m_vQuestOver, iQuestId)
        break
      end
    end
  end
  if 0 < #vQuestStatusChanged then
    self:broadcastEvent("eGameEvent_Activity_CommonQuest_UpdateQuest", {
      iActivityID = self:getID(),
      vQuestStatusChanged = vQuestStatusChanged
    })
  end
end

function CommonQuestActivity:isAllTaskFinished()
  local isAllFinished = true
  for i = 1, iDayMax do
    if not self:IsDailyRewardTaken(i) then
      isAllFinished = false
      break
    end
  end
  if not next(self.m_vQuest) and #self.m_stStatusData.vTakenFinalReward == iMaxScoreRewardCount and isAllFinished then
    return true
  end
  return false
end

function CommonQuestActivity:GetActiveDay()
  return self.m_iDayNum > iDayMax and iDayMax or self.m_iDayNum
end

function CommonQuestActivity:GetUIType()
  return self.m_UIType
end

function CommonQuestActivity:GetUpActivityID()
  return self.m_UpActivityID
end

function CommonQuestActivity:GetActMaxDay()
  return iDayMax
end

function CommonQuestActivity:ResetCommonQuestRefreshTime()
  self.m_iNextRefreshTime = TimeUtil:GetServerNextCommonResetTime()
end

function CommonQuestActivity:GetCommonQuestRefreshTime()
  return self.m_iNextRefreshTime or TimeUtil:GetServerNextCommonResetTime()
end

function CommonQuestActivity:GetQuestStatusByID(iQuestID)
  for _, stQuestStatus in pairs(self.m_vQuest) do
    if stQuestStatus.iId == iQuestID then
      return stQuestStatus
    end
  end
  local stQuestStatus = MTTDProto.CmdQuest()
  stQuestStatus.iId = iQuestID
  stQuestStatus.iType = self:getID()
  stQuestStatus.iAcceptTime = 0
  stQuestStatus.vCondStep = {}
  for _, iQuestIDTmp in pairs(self.m_vQuestOver) do
    if iQuestIDTmp == iQuestID then
      stQuestStatus.iState = MTTDProto.QuestState_Over
      return stQuestStatus
    end
  end
  stQuestStatus.iState = MTTDProto.QuestState_Doing
  return stQuestStatus
end

function CommonQuestActivity:GetQuestInfo(iDay)
  local vQuestInfo = {}
  for _, stQuestConfig in pairs(self.m_mQuestConfig) do
    if iDay == nil or stQuestConfig.iOpenDay == iDay then
      local stQuestInfo = {}
      stQuestInfo.stQuestConfig = stQuestConfig
      stQuestInfo.stQuestStatus = self:GetQuestStatusByID(stQuestConfig.iId)
      table.insert(vQuestInfo, stQuestInfo)
    end
  end
  return vQuestInfo
end

function CommonQuestActivity:GetScore(iDay)
  local iScore = 0
  for _, iQuestID in pairs(self.m_vQuestOver) do
    local stQuestConfig = self.m_mQuestConfig[iQuestID]
    if stQuestConfig and (iDay == nil or stQuestConfig.iOpenDay == iDay) then
      iScore = iScore + stQuestConfig.iScore
    end
  end
  return iScore
end

function CommonQuestActivity:GetDailyRewardConfig(iDay)
  return self.m_mDailyRewardConfig[iDay]
end

function CommonQuestActivity:GetDailyRewardTakenInfo()
  return self.m_stStatusData.vTakenDailyReward or {}
end

function CommonQuestActivity:IsDailyRewardTaken(iDay)
  local vDailyRewardTakenInfo = self:GetDailyRewardTakenInfo()
  for _, iTakenOpenDay in ipairs(vDailyRewardTakenInfo) do
    if iTakenOpenDay == iDay then
      return true
    end
  end
  return false
end

function CommonQuestActivity:GetFinalRewardConfig()
  return self.m_mFinalRewardConfig or {}
end

function CommonQuestActivity:GetFinalRewardTakenInfo()
  return self.m_stStatusData.vTakenFinalReward or {}
end

function CommonQuestActivity:checkCondition(bIsShow)
  if not CommonQuestActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if bIsShow and self:isAllTaskFinished() then
    return false
  end
  return true
end

function CommonQuestActivity:isInActivityShowTime()
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

function CommonQuestActivity:CheckShowRedByDay(iDay)
  if iDay == nil or iDay > self:GetActiveDay() then
    return false
  end
  local iScoreCur = self:GetScore(iDay)
  local stDailyRewardConfig = self:GetDailyRewardConfig(iDay)
  if stDailyRewardConfig ~= nil and not self:IsDailyRewardTaken(iDay) and iScoreCur >= stDailyRewardConfig.iNeedScore then
    return true
  end
  local vQuestInfo = self:GetQuestInfo(iDay)
  for _, stQuestInfo in ipairs(vQuestInfo) do
    if stQuestInfo.stQuestStatus.iState == MTTDProto.QuestState_Finish then
      return true
    end
  end
  return false
end

function CommonQuestActivity:CheckShowRedFinalReward()
  local iScoreCur = self:GetScore()
  local mFinalRewardConfig = self:GetFinalRewardConfig()
  local vFinalRewardTakenInfo = self:GetFinalRewardTakenInfo()
  for iScoreTmp, stFinalRewardConfig in pairs(mFinalRewardConfig) do
    if iScoreTmp <= iScoreCur then
      local bTaken = false
      for _, iScoreTaken in ipairs(vFinalRewardTakenInfo) do
        if iScoreTmp == iScoreTaken then
          bTaken = true
          break
        end
      end
      if not bTaken then
        return true
      end
    end
  end
  return false
end

function CommonQuestActivity:IsFinalRewardReceived()
  local vFinalRewardTakenInfo = self:GetFinalRewardTakenInfo()
  for _, iScoreTaken in ipairs(vFinalRewardTakenInfo) do
    if iScoreTaken == self.iFinalScore then
      return true
    end
  end
  return false
end

function CommonQuestActivity:checkShowRed()
  if not self:checkCondition() then
    return false
  end
  if self:CheckShowRedFinalReward() then
    return true
  end
  local curDay = math.min(self.m_iDayNum or iDayMax, iDayMax)
  for i = 1, curDay do
    if self:CheckShowRedByDay(i) then
      return true
    end
  end
  return false
end

function CommonQuestActivity:HasPopupToday()
  if self.m_iPopupTime == nil then
    self.m_iPopupTime = LocalDataManager:GetIntSimple("Activity_CommonQuest_Popup", 0)
  end
  return self.m_iPopupTime > TimeUtil:GetServerTimeS()
end

function CommonQuestActivity:SetHasPopupToday()
  self.m_iPopupTime = TimeUtil:GetServerNextCommonResetTime()
  LocalDataManager:SetIntSimple("Activity_CommonQuest_Popup", self.m_iPopupTime)
end

function CommonQuestActivity:RequestTakeQuestReward(vQuestId)
  local function OnTaskQuestRewardSC(sc, msg)
    self:broadcastEvent("eGameEvent_Activity_CommonQuest_TakeQuestReward", sc)
  end
  
  local reqMsg = MTTDProto.Cmd_Quest_TakeReward_CS()
  reqMsg.iQuestType = self:getID()
  reqMsg.vQuestId = vQuestId
  RPCS():Quest_TakeReward(reqMsg, OnTaskQuestRewardSC)
end

function CommonQuestActivity:RqsTakeOneDayAllReward(iDay)
  local vQuestId = {}
  local vQuestInfo = self:GetQuestInfo(iDay)
  for _, stQuestInfo in ipairs(vQuestInfo) do
    if stQuestInfo.stQuestStatus.iState == MTTDProto.QuestState_Finish then
      table.insert(vQuestId, stQuestInfo.stQuestConfig.iId)
    end
  end
  self:RequestTakeQuestReward(vQuestId)
end

function CommonQuestActivity:RequestTakeDailyReward(iDay)
  local function OnTaskDailyRewardSC(sc, msg)
    self.m_stStatusData.vTakenDailyReward = self.m_stStatusData.vTakenDailyReward or {}
    
    table.insert(self.m_stStatusData.vTakenDailyReward, iDay)
    self:broadcastEvent("eGameEvent_Activity_CommonQuest_TakeDailyReward", sc)
  end
  
  local reqMsg = MTTDProto.Cmd_Act_CommonQuest_TakeDailyReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iDay = iDay
  RPCS():Act_CommonQuest_TakeDailyReward(reqMsg, OnTaskDailyRewardSC)
end

function CommonQuestActivity:RequestTakeFinalReward(iScore)
  local function OnTaskFinalRewardSC(sc, msg)
    self.m_stStatusData.vTakenFinalReward = self.m_stStatusData.vTakenFinalReward or {}
    
    table.insert(self.m_stStatusData.vTakenFinalReward, iScore)
    self:broadcastEvent("eGameEvent_Activity_CommonQuest_TakeFinalReward", sc)
  end
  
  local reqMsg = MTTDProto.Cmd_Act_CommonQuest_TakeFinalReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iScore = iScore
  RPCS():Act_CommonQuest_TakeFinalReward(reqMsg, OnTaskFinalRewardSC)
end

return CommonQuestActivity
