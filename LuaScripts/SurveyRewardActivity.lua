local BaseActivity = require("Base/BaseActivity")
local SurveyRewardActivity = class("SurveyRewardActivity", BaseActivity)

function SurveyRewardActivity.getActivityType(_)
  return MTTD.ActivityType_SurveyReward
end

function SurveyRewardActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgSurveyReward
end

function SurveyRewardActivity.getStatusProto(_)
  return MTTDProto.CmdActSurveyReward_Status
end

function SurveyRewardActivity:RequestGetSurveyLink(iIndex)
  if self:IsSubmitSurvey() then
    utils.CheckAndPushCommonTips({
      tipsID = 1153,
      func1 = function()
        StackTop:RemoveUIFromStack(UIDefines.ID_FORM_COMMONTIPS)
      end
    })
    return
  end
  local reqMsg = MTTDProto.Cmd_Act_SurveyReward_GetLink_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iIndexId = iIndex
  RPCS():Act_SurveyReward_GetLink(reqMsg, handler(self, self.OnRequestGetSurveyLinkSC))
end

function SurveyRewardActivity:OnRequestGetSurveyLinkSC(stData, msg)
  local link = stData.sLink
  log.error("拿到链接了")
  StackPopup:Push(UIDefines.ID_FORM_WEBVIEWFULLSCREEN, {url = link})
  ReportManager:ReportSystemModuleOpen("问卷", link)
end

function SurveyRewardActivity:SetSurveyRewardStatus(iIndex, state)
  self.m_getSurveyRewardStatusList[iIndex] = state
end

function SurveyRewardActivity:RequestGetSurveyReward(iIndex)
  local reqMsg = MTTDProto.Cmd_Act_SurveyReward_GetReward_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iIndexId = iIndex
  RPCS():Act_SurveyReward_GetReward(reqMsg, handler(self, self.OnRequestGetRewardSC))
end

function SurveyRewardActivity:OnRequestGetRewardSC(sc, msg)
  local vReward = sc.vReward
  self.m_getSurveyRewardStatusList[sc.iIndexId] = MTTDProto.SurveyRewardStatus_Reward
  utils.popUpRewardUI(vReward)
  self:broadcastEvent("eGameEvent_Activity_SurveyReward")
end

function SurveyRewardActivity:OnResetSdpConfig()
  self.m_vInfoList = {}
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    for iIndex, stInfo in pairs(self.m_stSdpConfig.stCommonCfg.mReward) do
      stInfo.stRewardInfo = stInfo.sReward
      self.m_vInfoList[checknumber(iIndex)] = stInfo
    end
  end
end

function SurveyRewardActivity:OnResetStatusData()
  self.m_getSurveyRewardStatusList = {}
  if self.m_stStatusData and self.m_stStatusData.iActivityId == self:getID() and self.m_stStatusData.mSendReward then
    self.m_getSurveyRewardStatusList = self.m_stStatusData.mSendReward
  end
end

function SurveyRewardActivity:checkCondition()
  if not SurveyRewardActivity.super.checkCondition(self) then
    return false
  end
  if not self:IsInActivityTime() then
    return false
  end
  return true
end

function SurveyRewardActivity:GetInfoList()
  return self.m_vInfoList
end

function SurveyRewardActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iBeginTime == 0 or self.m_stActivityData.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function SurveyRewardActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

function SurveyRewardActivity:IsPassActivityConditionsStage()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iStageMax == 0 and self.m_stActivityData.iStageMin == 0 then
    return true
  end
  local openFlag = false
  if self.m_stActivityData.iStageMin ~= 0 then
    openFlag = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, self.m_stActivityData.iStageMin)
  end
  if self.m_stActivityData.iStageMax ~= 0 then
    openFlag = not LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, self.m_stActivityData.iStageMax)
  end
  return openFlag
end

function SurveyRewardActivity:IsActivityReachesTargetLevel()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iMinLevel == 0 and self.m_stActivityData.iMaxLevel == 0 then
    return true
  end
  local openFlag = false
  if self.m_stActivityData.iMinLevel ~= 0 then
    openFlag = (RoleManager:GetLevel() or 0) > self.m_stActivityData.iMinLevel
  end
  if self.m_stActivityData.iMaxLevel ~= 0 then
    openFlag = (RoleManager:GetLevel() or 0) < self.m_stActivityData.iMaxLevel
  end
  return openFlag
end

function SurveyRewardActivity:CheckActivityIsOpen()
  local openFlag = false
  if self:IsInActivityShowTime() and self:IsPassActivityConditionsStage() and self:IsActivityReachesTargetLevel() then
    openFlag = true
  end
  return openFlag
end

function SurveyRewardActivity:GetSurveyRewardStatus()
  return self.m_getSurveyRewardStatusList
end

function SurveyRewardActivity:IsSubmitSurvey()
  local isReadySubmit = false
  local state = MTTDProto.SurveyRewardStatus_None
  if self:CheckActivityIsOpen() then
    state = self:GetSurveyRewardStatus()[1] or MTTDProto.SurveyRewardStatus_None
    isReadySubmit = state ~= MTTDProto.SurveyRewardStatus_None
    return isReadySubmit
  end
end

return SurveyRewardActivity
