local BaseActivity = require("Base/BaseActivity")
local GameNoticeActivity = class("GameNoticeActivity", BaseActivity)
local UITypeSubPanel = {
  [1] = "AnnouncementPushFaceGachaSubPanel",
  [2] = "AnnouncementPushFacePersonalRaidSubPanel",
  [3] = "AnnouncementPushFaceGuildRaidSubPanel",
  [4] = "AnnouncementPushFaceHuntingSubPanel"
}
local RewardType = {PushFaceReward = 1}

function GameNoticeActivity.getActivityType(_)
  return MTTD.ActivityType_GameNotice
end

function GameNoticeActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgGameNotice
end

function GameNoticeActivity.getStatusProto(_)
  return MTTDProto.CmdActGameNotice_Status
end

function GameNoticeActivity:OnResetSdpConfig()
  self.m_vNoticeList = {}
  if self.m_stSdpConfig then
    for iIndex, stInfo in pairs(self.m_stSdpConfig.stClientCfg) do
    end
  end
  if self.m_stSdpConfig and self.m_stSdpConfig.stClientCfg and self.m_stSdpConfig.stClientCfg.iNoticeType == 4 then
    local sClientVersion, iQuestId = self:GetAddResPreConfig()
    DownloadManager:DownloadPreInitStatus(iQuestId, sClientVersion)
  end
end

function GameNoticeActivity:GetActiveAnnouncementList()
  return self.m_activityAnnouncement
end

function GameNoticeActivity:GetSystemAnnouncementList()
  return self.m_systemAnnouncement
end

function GameNoticeActivity:checkShowRed()
  if not self:checkCondition() then
    return false
  end
  local isShowRed = false
  local isPushJumpAnnouncement = self:CheckIsPushJumpAnnouncement()
  if isPushJumpAnnouncement then
    if self:GetPushJumpIsGotReward() then
      isShowRed = false
    else
      isShowRed = ActivityManager:CanShowRedCurrentLogin(self:getID())
      if not isShowRed then
        local reward = self:GetPushJumpWindowRewardReward()
        if reward and table.getn(reward) > 0 and self:GetPushJumpWindowRewardTime() < TimeUtil:GetServerTimeS() then
          isShowRed = true
        end
      end
    end
  else
    isShowRed = ActivityManager:CanShowRedCurrentLogin(self:getID())
  end
  return isShowRed
end

function GameNoticeActivity:checkCondition()
  if not self.m_stActivityData then
    return false
  end
  if not GameNoticeActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if not self:isInActivityShowTime() then
    return false
  end
  if self.m_stSdpConfig.stClientCfg.iNeedChargeMoney and self.m_stSdpConfig.stClientCfg.iNeedChargeMoney > RoleManager:GetTotalRecharge() then
    return false
  end
  if not self:IsShowSurveyAnnounce() then
    return false
  end
  if not self:isInActivityLanguageShow() then
    return false
  end
  return true
end

function GameNoticeActivity:isInActivityLanguageShow()
  if self.m_stActivityData.vLanguageId then
    local langId = CS.MultiLanguageManager.g_iLanguageID
    langId = CS.MultiLanguageManager.Instance:GetLanIDById(langId)
    local langList = self.m_stActivityData.vLanguageId or {}
    if table.getn(langList) > 0 then
      for k, v in pairs(langList) do
        if v == langId then
          return true
        end
      end
    else
      return true
    end
  end
  return false
end

function GameNoticeActivity:OnResetStatusData()
end

function GameNoticeActivity:IsShowSurveyAnnounce()
  local paramArray = string.split(self.m_stSdpConfig.stClientCfg.sJumpParamLast, "|")
  if paramArray[1] and paramArray[2] then
    local activity = ActivityManager:GetActivityByID(tonumber(paramArray[2]))
    if activity then
      local activityType = activity:getType()
      if activityType == MTTD.ActivityType_SurveyReward and paramArray[3] and tonumber(paramArray[3]) == 0 and activity:IsSubmitSurvey() then
        return false
      end
    end
  end
  return true
end

function GameNoticeActivity:GetAnnouncementShowWeight()
  return self.m_stSdpConfig.stClientCfg.iShowWeight or 0
end

function GameNoticeActivity:GetPushJumpData()
  local pushFaceJump = self.m_stSdpConfig.stClientCfg.vJumpContent
  if table.getn(pushFaceJump) > 0 then
    return pushFaceJump[1]
  end
end

function GameNoticeActivity:CheckIsPushJumpAnnouncement()
  local pushFaceJump = self.m_stSdpConfig.stClientCfg.vJumpContent
  if table.getn(pushFaceJump) > 0 then
    return true
  end
  return false
end

function GameNoticeActivity:GetPushJumpIsGotReward()
  if self.m_stStatusData then
    return self.m_stStatusData.bIsRewarded or false
  end
  return false
end

function GameNoticeActivity:GetPushJumpSubPanelWithUiType()
  local pushFaceJump = self.m_stSdpConfig.stClientCfg.vJumpContent
  if table.getn(pushFaceJump) > 0 then
    return UITypeSubPanel[pushFaceJump[1].type]
  end
end

function GameNoticeActivity:GetPushJumpTimeWindow()
  local pushFaceJump = self.m_stSdpConfig.stClientCfg.vJumpContent
  if table.getn(pushFaceJump) > 0 then
    return pushFaceJump[1].iActivityOpenTime, pushFaceJump[1].iActivityEndTime
  end
end

function GameNoticeActivity:GetPushJumpWindowRewardTime()
  local commonCfg = self.m_stSdpConfig.stCommonCfg
  return commonCfg.iCanGetRewardTime or 0
end

function GameNoticeActivity:GetPushJumpGetRewardType()
  local commonCfg = self.m_stSdpConfig.stCommonCfg
  return commonCfg.reward_type
end

function GameNoticeActivity:ReqGetRewardCS()
  if not self:checkCondition() then
    return
  end
  local getRewardType = self:GetPushJumpGetRewardType()
  if getRewardType == RewardType.PushFaceReward then
    local isGot = self:GetPushJumpIsGotReward()
    local rewardTime = self:GetPushJumpWindowRewardTime()
    if isGot or rewardTime > TimeUtil:GetServerTimeS() then
      return
    end
    local reqMsg = MTTDProto.Cmd_Act_GameNotice_ReqGetWard_CS()
    reqMsg.iActivityId = self:getID()
    RPCS():Act_GameNotice_ReqGetWard(reqMsg, function(sc, msg)
      utils.popUpRewardUI(sc.vReward)
      self:broadcastEvent("eGameEvent_Activity_PushFaceReserve", {
        iActivityID = self:getID()
      })
    end)
  end
end

function GameNoticeActivity:GetPushJumpWindowRewardReward()
  local commonCfg = self.m_stSdpConfig.stCommonCfg
  return commonCfg.mReward
end

function GameNoticeActivity:GetAddResPreConfig()
  local iNoticeType
  if self.m_stSdpConfig and self.m_stSdpConfig.stClientCfg and self.m_stSdpConfig.stClientCfg.iNoticeType == 4 then
    iNoticeType = self.m_stSdpConfig.stClientCfg.iNoticeType
  end
  if iNoticeType ~= 4 then
    return nil, nil
  end
  local sClientVersion = self.m_stSdpConfig.stClientCfg.sClientVersion
  local iQuestId = self.m_stSdpConfig.stClientCfg.iQuestId
  return sClientVersion, iQuestId
end

function GameNoticeActivity:CanShowAddResPre()
  local iHideTime
  if self.m_stSdpConfig and self.m_stSdpConfig.stClientCfg and self.m_stSdpConfig.stClientCfg.iHideTime then
    iHideTime = self.m_stSdpConfig.stClientCfg.iHideTime
  end
  local iServerTime = TimeUtil:GetServerTimeS()
  if iHideTime and iHideTime < iServerTime then
    return false
  end
  return true
end

return GameNoticeActivity
