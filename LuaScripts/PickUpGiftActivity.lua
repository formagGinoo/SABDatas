local BaseActivity = require("Base/BaseActivity")
local PickUpGiftActivity = class("PickUpGiftActivity", BaseActivity)

function PickUpGiftActivity.getActivityType(_)
  return MTTD.ActivityType_PickupGift
end

function PickUpGiftActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgPickupGift
end

function PickUpGiftActivity.getStatusProto(_)
  return MTTDProto.CmdActPickupGift_Status
end

function PickUpGiftActivity:OnResetSdpConfig()
  self.mGiftList = {}
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg and self.m_stSdpConfig.stCommonCfg.mGiftList then
    local list = self.m_stSdpConfig.stCommonCfg.mGiftList
    for _, v in pairs(list) do
      self.mGiftList[v.iOrder] = v
    end
  end
end

function PickUpGiftActivity:OnResetStatusData()
  self.mGiftInfo = {}
  if self.m_stStatusData then
    self.mGiftInfo = self.m_stStatusData.mGift
    for _, v in ipairs(self.mGiftList) do
      local cfgList = v.stGrids.mGridCfg
      local giftInfo = self.mGiftInfo[v.iGiftId] or {}
      giftInfo.mGridRewardIndex = giftInfo.mGridRewardIndex or {}
      giftInfo.iBoughtNum = giftInfo.iBoughtNum or 0
      for i, rewards in ipairs(cfgList) do
        if #rewards == 1 then
          giftInfo.mGridRewardIndex[i] = 0
        end
      end
      self.mGiftInfo[v.iGiftId] = giftInfo
    end
  end
  self:broadcastEvent("eGameEvent_Activity_ResetStatus")
end

function PickUpGiftActivity:checkCondition()
  if not PickUpGiftActivity.super.checkCondition(self) then
    return false
  end
  if not self:IsInActivityTime() then
    return false
  end
  return true
end

function PickUpGiftActivity:GetPickUpGiftList()
  return self.mGiftList
end

function PickUpGiftActivity:GetPickUpGifyInfo()
  return self.mGiftInfo
end

function PickUpGiftActivity:RqsSetReward(iGiftId, mGridRewardIndex)
  local msg = MTTDProto.Cmd_Act_PickupGift_SetReward_CS()
  msg.iActivityId = self:getID()
  msg.iGiftId = iGiftId
  msg.mGridRewardIndex = mGridRewardIndex
  RPCS():Act_PickupGift_SetReward(msg, function()
  end)
end

function PickUpGiftActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iBeginTime == 0 or self.m_stActivityData.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function PickUpGiftActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

return PickUpGiftActivity
