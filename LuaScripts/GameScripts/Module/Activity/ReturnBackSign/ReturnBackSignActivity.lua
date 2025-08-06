local BaseActivity = require("Base/BaseActivity")
local ReturnBackSignActivity = class("ReturnBackSignActivity", BaseActivity)

function ReturnBackSignActivity.getActivityType(_)
  return MTTD.ActivityType_ReturnSign
end

function ReturnBackSignActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgReturnSign
end

function ReturnBackSignActivity.getStatusProto(_)
  return MTTDProto.CmdActReturnSign_Status
end

function ReturnBackSignActivity:OnResetSdpConfig()
end

function ReturnBackSignActivity:checkShowRed()
  if self:checkCondition() then
    local statusData = self:getStatusData()
    if not statusData then
      return false
    end
    local curLoginDay = statusData.iLoginDay or 0
    local haveGetRewardDay = statusData.iMaxAwardedDays or 0
    local commonCfg = self:GetCommonCfg()
    if not commonCfg then
      return false
    end
    local maxDay = #commonCfg.mReward
    if curLoginDay > maxDay then
      return false
    end
    return curLoginDay > haveGetRewardDay
  end
  return false
end

function ReturnBackSignActivity:checkCondition()
  if not ReturnBackSignActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if not self:isInActivityShowTime() then
    return false
  end
  if not self:IsInStatusOpenTime() then
    return false
  end
  return true
end

function ReturnBackSignActivity:IsInStatusOpenTime()
  local statusData = self:getStatusData()
  if not statusData then
    return false
  end
  if statusData.iOpenTime == 0 and statusData.iCloseTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(statusData.iOpenTime, statusData.iCloseTime)
end

function ReturnBackSignActivity:GetCommonCfg()
  if not self.m_stSdpConfig then
    return
  end
  return self.m_stSdpConfig.stCommonCfg
end

function ReturnBackSignActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_ReturnBackSignActivity
end

function ReturnBackSignActivity:getActivityEndTime()
  local statusData = self:getStatusData()
  if not statusData then
    return
  end
  return statusData.iCloseTime
end

function ReturnBackSignActivity:GetReturnBackSignRewardList()
  if not self.m_stSdpConfig then
    return
  end
  local stCommonCfg = self:GetCommonCfg()
  if not stCommonCfg then
    return
  end
  local statusData = self:getStatusData()
  if not statusData then
    return
  end
  local curLoginDay = statusData.iLoginDay or 0
  local haveGetRewardDay = statusData.iMaxAwardedDays or 0
  local rewardList = stCommonCfg.mReward
  local showSignRewardList = {}
  for i, v in ipairs(rewardList) do
    if v then
      local isHaveRcv = i <= haveGetRewardDay
      local isCanGet = i > haveGetRewardDay and i <= curLoginDay
      local isLock = i > curLoginDay
      local tempSignData = {
        isRcv = isHaveRcv,
        isCanGet = isCanGet,
        isLock = isLock,
        itemData = v
      }
      showSignRewardList[#showSignRewardList + 1] = tempSignData
    end
  end
  return showSignRewardList
end

function ReturnBackSignActivity:ReqActReturnSignGetSignReward()
  local activityID = self:getID()
  if not activityID then
    return
  end
  local msg = MTTDProto.Cmd_Act_ReturnSign_GetSignReward_CS()
  msg.iActivityId = activityID
  RPCS():Act_ReturnSign_GetSignReward(msg, handler(self, self.OnGetSignRewardSC))
end

function ReturnBackSignActivity:OnGetSignRewardSC(stSignReward, msg)
  if not stSignReward then
    return
  end
  local activityId = self:getID()
  if stSignReward.iActivityId ~= activityId then
    return
  end
  self.m_stStatusData.iMaxAwardedDays = stSignReward.iMaxAwardedDays
  self:broadcastEvent("eGameEvent_Activity_ReturnBackSign_Reward", stSignReward)
end

return ReturnBackSignActivity
