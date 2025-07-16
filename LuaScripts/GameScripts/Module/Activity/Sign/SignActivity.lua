local BaseActivity = require("Base/BaseActivity")
local SignActivity = class("SignActivity", BaseActivity)
local SignType = {
  thirtySign = 0,
  SevenSign = 1,
  FiveSign = 2,
  FourTeenSign = 3
}
local SignLimitCondition = {
  MainLevel = 1,
  TowerLevel = 3,
  UpActLevel = 5
}

function SignActivity.getActivityType(_)
  return MTTD.ActivityType_Sign
end

function SignActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgSign
end

function SignActivity.getStatusProto(_)
  return MTTDProto.CmdActSign_Status
end

function SignActivity:OnResetSdpConfig()
  self.m_vSignInfoList = {}
  for iIndex, stSignInfo in pairs(self.m_stSdpConfig.mReward) do
    local vRewarParamsTotal = string.split(stSignInfo.sReward, ";")
    stSignInfo.stRewardInfo = {}
    for i = 1, #vRewarParamsTotal do
      local vRewardParams = string.split(vRewarParamsTotal[i], ",")
      stSignInfo.stRewardInfo[i] = {
        iID = tonumber(vRewardParams[1]),
        iNum = tonumber(vRewardParams[2])
      }
    end
    self.m_vSignInfoList[checknumber(iIndex)] = stSignInfo
  end
  self:ResetSignRefreshTime()
end

function SignActivity:OnResetStatusData()
  self.m_stActivityData.iBeginTime = self.m_stStatusData.iBeginTime
  self.m_stActivityData.iEndTime = self.m_stStatusData.iEndTime
  self.m_stActivityData.iShowTimeBegin = self.m_stStatusData.iBeginTime
  self.m_stActivityData.iShowTimeEnd = self.m_stStatusData.iEndTime
end

function SignActivity:OnPushPanel()
  if self:checkShowRed() and self:isInActivityShowTime() then
    self:broadcastEvent("eGameEvent_ActivityDailyLogin", self:getSubPanelName())
  end
end

function SignActivity:ResetSignRefreshTime()
  self.m_iNextRefreshTime = TimeUtil:GetServerNextCommonResetTime()
end

function SignActivity:GetSignRefreshTime()
  return self.m_iNextRefreshTime or TimeUtil:GetServerNextCommonResetTime()
end

function SignActivity:checkCondition(bIsShow)
  if not SignActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if not (self.m_stStatusData and self.m_stStatusData.iActivityId) or self.m_stStatusData.iActivityId == 0 then
    return false
  end
  if bIsShow and self:GetSignNum() >= #self:GetSignInfoList() then
    return false
  end
  if not self:CheckOtherLevelCondition() then
    return false
  end
  return true
end

function SignActivity:CheckOtherLevelCondition()
  local isShow = true
  local levelId = self.m_stSdpConfig.iRestrictStageId
  if levelId and levelId ~= 0 then
    if self.m_stSdpConfig.iRestrictStageType == SignLimitCondition.MainLevel then
      isShow = LevelManager:IsLevelHavePass(LevelManager.LevelType.MainLevel, levelId)
    elseif self.m_stSdpConfig.iRestrictStageType == SignLimitCondition.TowerLevel then
      isShow = LevelManager:IsLevelHavePass(LevelManager.LevelType.TowerLevel, levelId)
    elseif self.m_stSdpConfig.iRestrictStageType == SignLimitCondition.UpActLevel then
      local actData = LevelHeroLamiaActivityManager:GetLevelHelper():IsHaveActDataBylevelId(levelId)
      if actData then
        isShow = LevelHeroLamiaActivityManager:GetLevelHelper():IsLevelHavePass(levelId)
      else
        isShow = not self:getStatusData().bStageRestrict
      end
    end
  end
  if self.m_stSdpConfig.iRestrictGuideId and self.m_stSdpConfig.iRestrictGuideId ~= 0 then
    isShow = GuideManager:CheckSubStepGuideCmp(self.m_stSdpConfig.iRestrictGuideId)
  end
  return isShow
end

function SignActivity:GetSignInfoList()
  return self.m_vSignInfoList
end

function SignActivity:GetSignNum()
  return self:getStatusData().iSignNum
end

function SignActivity:IsSignToday()
  return self:getStatusData().bSignToday
end

function SignActivity:isAllTaskFinished()
  local isAllFinished = self:getStatusData().iSignNum >= #self.m_vSignInfoList
  return isAllFinished
end

function SignActivity:checkShowRed()
  if not self:checkCondition(true) then
    return false
  end
  if not (self.m_stStatusData and self.m_stStatusData.iActivityId) or self.m_stStatusData.iActivityId == 0 then
    return false
  end
  if self:GetSignNum() >= #self:GetSignInfoList() then
    return false
  end
  if self:IsSignToday() then
    return false
  end
  return true
end

function SignActivity:HasPopupToday()
  if self.m_iPopupTime == nil then
    self.m_iPopupTime = LocalDataManager:GetIntSimple("Activity_Sign_Popup", 0)
  end
  return self.m_iPopupTime > TimeUtil:GetServerTimeS()
end

function SignActivity:SetHasPopupToday()
  self.m_iPopupTime = TimeUtil:GetServerNextCommonResetTime()
  LocalDataManager:SetIntSimple("Activity_Sign_Popup", self.m_iPopupTime)
end

function SignActivity:RequestSign(iIndex, NoPopWindow)
  local reqMsg = MTTDProto.Cmd_Act_Sign_Sign_CS()
  reqMsg.iActivityId = self:getID()
  reqMsg.iIndex = iIndex
  RPCS():Act_Sign_Sign(reqMsg, function(sc, msg)
    if not NoPopWindow then
      local vCharacter = {}
      local vReward = {}
      for k, v in ipairs(sc.vReward) do
        table.insert(vReward, {
          iID = v.iID,
          iNum = v.iNum
        })
        local stItemData = CS.CData_Item.GetInstance():GetValue_ByItemID(v.iID)
        if stItemData and stItemData.m_ItemType == ItemManager.ItemType.Character then
          table.insert(vCharacter, v)
        end
      end
      self:broadcastEvent("eGameEvent_Activity_Sign_UpdateSign", {
        iActivityID = self:getID(),
        vReward = vReward,
        vCharacter = vCharacter
      })
    end
  end)
end

function SignActivity:getSubPanelName()
  if self.m_stSdpConfig.iUiType == SignType.SevenSign then
    return ActivityManager.ActivitySubPanelName.ActivitySPName_Sign7
  elseif self.m_stSdpConfig.iUiType == SignType.FourTeenSign then
    return ActivityManager.ActivitySubPanelName.ActivitySPName_Sign14
  end
end

function SignActivity:GetSignPushFacePrefabName()
  if self.m_stSdpConfig.iUiType == SignType.SevenSign then
    return "Form_ActivitySevendaysFace"
  elseif self.m_stSdpConfig.iUiType == SignType.FourTeenSign then
    return "Form_ActivityFourteendaysFace"
  end
  return ""
end

function SignActivity:OnDispose()
  local formId = -1
  if self.m_stSdpConfig and self.m_stSdpConfig.iUiType == SignType.SevenSign then
    formId = UIDefines.ID_FORM_ACTIVITYSEVENDAYSFACE
  elseif self.m_stSdpConfig and self.m_stSdpConfig.iUiType == SignType.FourTeenSign then
    formId = UIDefines.ID_FORM_ACTIVITYFOURTEENDAYSFACE
  end
  PushFaceManager:RemoveShowPopPanelList(UIDefines.ID_FORM_ACTIVITYSEVENDAYSFACE, self:getSubPanelName())
end

return SignActivity
