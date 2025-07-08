local BaseActivity = require("Base/BaseActivity")
local SignGiftActivity = class("SignGiftActivity", BaseActivity)
local maxRewardDay = 5

function SignGiftActivity.getActivityType(_)
  return MTTD.ActivityType_SignGift
end

function SignGiftActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgSignGift
end

function SignGiftActivity.getStatusProto(_)
  return MTTDProto.CmdActSignGift_Status
end

function SignGiftActivity:OnResetSdpConfig()
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    self.m_rewardList = self.m_stSdpConfig.stCommonCfg.mReward
    self.m_productId = self.m_stSdpConfig.stCommonCfg.sProductId
    self.m_ForbidBuyHourBeforeEnd = self.m_stSdpConfig.stCommonCfg.iForbidBuyHourBeforEnd
  end
end

function SignGiftActivity:OnResetStatusData()
  self.m_loginDays = 0
  self.m_maxRewardDays = 0
  self.m_buyTimes = 0
  self.m_lastBuyTimes = 0
  if self.m_stStatusData then
    self.m_loginDays = self.m_stStatusData.iLoginDays
    self.m_maxRewardDays = self.m_stStatusData.iMaxAwardedDays
    self.m_buyTimes = self.m_stStatusData.iBuyTimes
  end
  if self.m_lastBuyTimes ~= self.m_buyTimes then
    self:broadcastEvent("eGameEvent_Activity_SignGift_FirstReward", {
      iActivityID = self:getID()
    })
  end
end

function SignGiftActivity:GetCommonCfg()
  return self.m_stSdpConfig.stCommonCfg
end

function SignGiftActivity:checkShowRed()
  if not self:checkCondition() then
    return false
  end
  if self.m_buyTimes and self.m_buyTimes > 0 and self.m_maxRewardDays < self.m_loginDays and self.m_maxRewardDays < maxRewardDay then
    return true
  end
  return false
end

function SignGiftActivity:GetBuyTimes(_)
  return self.m_buyTimes
end

function SignGiftActivity:GetRewardList(_)
  return self.m_rewardList
end

function SignGiftActivity:GetClientData(_)
  return self.m_stSdpConfig.stClientCfg
end

function SignGiftActivity:GetLoginDays(_)
  return self.m_loginDays or 0
end

function SignGiftActivity:GetMaxGetRewardDays(_)
  return self.m_maxRewardDays or 0
end

function SignGiftActivity:getStatusProto(_)
  return MTTDProto.CmdActSignGift_Status
end

function SignGiftActivity:checkCondition()
  if not SignGiftActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  if not self:CheckOtherCondition() then
    return false
  end
  return true
end

function SignGiftActivity:GetLimitBuyTimes()
  if self.m_ForbidBuyHourBeforeEnd and self.m_ForbidBuyHourBeforeEnd ~= 0 and 0 >= self.m_buyTimes then
    local endTime = self.m_stActivityData.iEndTime or 0
    if endTime ~= 0 then
      return endTime - self.m_ForbidBuyHourBeforeEnd * 3600
    end
  else
    return self.m_stActivityData.iEndTime
  end
end

function SignGiftActivity:CheckOtherCondition()
  if self.m_ForbidBuyHourBeforeEnd and self.m_ForbidBuyHourBeforeEnd ~= 0 and 0 >= self.m_buyTimes then
    local curTime = TimeUtil:GetServerTimeS()
    local endTime = self.m_stActivityData.iEndTime or 0
    if endTime ~= 0 then
      return curTime < endTime - self.m_ForbidBuyHourBeforeEnd * 3600
    end
  end
  return true
end

function SignGiftActivity:ReqGetReward()
  if self.m_loginDays <= self.m_maxRewardDays then
    return
  end
  local reqMsg = MTTDProto.Cmd_Act_SignGift_GetSignReward_CS()
  reqMsg.iActivityId = self:getID()
  RPCS():Act_SignGift_GetSignReward(reqMsg, function(sc, msg)
    local vReward = {}
    self.m_maxRewardDays = sc.iMaxAwardedDays
    for k, v in ipairs(sc.vReward) do
      table.insert(vReward, {
        iID = v.iID,
        iNum = v.iNum
      })
    end
    self:broadcastEvent("eGameEvent_Activity_SignGift_Reward", {
      iActivityID = self:getID(),
      vReward = vReward
    })
    self:broadcastEvent("eGameEvent_Activity_OtherRefreshRed")
  end)
end

return SignGiftActivity
