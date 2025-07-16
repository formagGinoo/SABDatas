local BaseActivity = require("Base/BaseActivity")
local PushGiftActivity = class("PushGiftActivity", BaseActivity)

function PushGiftActivity.getActivityType(_)
  return MTTD.ActivityType_PushGift
end

function PushGiftActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgPushGift
end

function PushGiftActivity.getStatusProto(_)
  return MTTDProto.CmdActPushGift_Status
end

function PushGiftActivity:OnResetSdpConfig()
  self.m_vInfoList = {}
  if not self.m_stSdpConfig then
    self.m_stSdpConfig = {}
  end
  if self.m_stSdpConfig.stCommonCfg and self.m_stSdpConfig.stCommonCfg.mPushGroup then
    self.m_vInfoList = self.m_stSdpConfig.stCommonCfg.mPushGroup
  end
end

function PushGiftActivity:GetInTimePushGift()
  local giftTab = {}
  local giftData = self.m_stStatusData
  if not (giftData and giftData.vPushGift) or table.getn(giftData.vPushGift) == 0 then
    return
  end
  for i, v in pairs(giftData.vPushGift) do
    local inTime = TimeUtil:IsInTime(TimeUtil:GetServerTimeS(), v.iExpireTime)
    if inTime then
      table.insert(giftTab, v)
    end
  end
  return giftTab
end

function PushGiftActivity:GetGiftDataByGroupAndGiftIndex(groupIndex, giftIndex)
  if self.m_vInfoList[groupIndex] and self.m_vInfoList[groupIndex].stPushGoodsConfig and self.m_vInfoList[groupIndex].stPushGoodsConfig.mGoods then
    return self.m_vInfoList[groupIndex].stPushGoodsConfig.mGoods[giftIndex]
  end
end

function PushGiftActivity:GetGiftGroupDataByGroupIndex(groupIndex)
  return self.m_vInfoList[groupIndex]
end

function PushGiftActivity:OnResetStatusData()
  self:broadcastEvent("eGameEvent_Activity_ResetStatus")
  local redPoint = self:GetPushGiftRedPoint()
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.MallPushGiftTab,
    count = redPoint
  })
end

function PushGiftActivity:GetPushGiftRedPoint()
  local redPoint = 0
  if self.m_stStatusData then
    local giftData = self.m_stStatusData
    if 0 < table.getn(giftData.vPushGift) then
      for i, v in pairs(giftData.vPushGift) do
        local inTime = TimeUtil:IsInTime(TimeUtil:GetServerTimeS(), v.iExpireTime)
        if inTime then
          local expireTime = LocalDataManager:GetIntSimple("Push_Gift_" .. tostring(v.iActivityID) .. tostring(v.iSubProductID), 0)
          if expireTime == 0 or expireTime ~= v.iExpireTime then
            redPoint = redPoint + 1
          end
        end
      end
    end
  end
  return redPoint
end

function PushGiftActivity:checkCondition()
  if not PushGiftActivity.super.checkCondition(self) then
    return false
  end
  if not self:IsInActivityTime() then
    return false
  end
  return true
end

function PushGiftActivity:GetInfoList()
  return self.m_vInfoList
end

function PushGiftActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iBeginTime == 0 or self.m_stActivityData.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function PushGiftActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

return PushGiftActivity
