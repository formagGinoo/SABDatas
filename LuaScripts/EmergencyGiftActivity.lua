local BaseActivity = require("Base/BaseActivity")
local EmergencyGiftActivity = class("EmergencyGiftActivity", BaseActivity)

function EmergencyGiftActivity.getActivityType(_)
  return MTTD.ActivityType_EmergencyGift
end

function EmergencyGiftActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgEmergencyGift
end

function EmergencyGiftActivity.getStatusProto(_)
  return MTTDProto.CmdActEmergencyGift_Status
end

function EmergencyGiftActivity:OnResetSdpConfig()
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg and self.m_stSdpConfig.stCommonCfg.mGift then
    self.m_packListCfg = self.m_stSdpConfig.stCommonCfg.mGift
  end
end

function EmergencyGiftActivity:OnResetStatusData()
  if self.m_stStatusData then
    self.m_needRandGiftId = self.m_stStatusData.vNeedRandGiftId
    self.m_pushPackList = {}
    if #self.m_stStatusData.vProductInfo > 0 then
      for _, v in pairs(self.m_stStatusData.vProductInfo) do
        if v then
          local giftInfo = {
            ProductInfo = v,
            GiftInfo = self.m_packListCfg[v.iGiftID]
          }
          self.m_pushPackList[#self.m_pushPackList + 1] = giftInfo
        end
      end
    end
    self:broadcastEvent("eGameEvent_Buy_EmergencyGift_Success")
  end
end

function EmergencyGiftActivity:checkCondition()
end

function EmergencyGiftActivity:GetPackCfgList()
  return self.m_packListCfg
end

function EmergencyGiftActivity:GetPackList()
  if self.m_pushPackList then
    for i = #self.m_pushPackList, 1, -1 do
      local giftInfo = self.m_pushPackList[i].GiftInfo
      local productInfo = self.m_pushPackList[i].ProductInfo
      self.m_endTime = productInfo.iTriggerTime + giftInfo.iGiftDuration
      if self.m_endTime < TimeUtil:GetServerTimeS() then
        table.remove(self.m_pushPackList, i)
      end
    end
  end
  return self.m_pushPackList or {}
end

function EmergencyGiftActivity:IsCanPushFace()
  if self.m_pushPackList then
    return #self.m_pushPackList > 0
  end
  return false
end

function EmergencyGiftActivity:CheckCanShowGift()
  self.m_canPushGift = {}
  if self.m_needRandGiftId then
    for _, v in pairs(self.m_needRandGiftId) do
      local giftInfo = self.m_packListCfg[v]
      local iTriggerRate = giftInfo.iTriggerRate
      local num = math.random(1, 1000)
      if iTriggerRate >= num then
        self.m_canPushGift[#self.m_canPushGift + 1] = giftInfo.iGiftID
      end
    end
    if #self.m_canPushGift > 0 then
      self:GetGiftProductInfo(self.m_canPushGift)
    end
  end
end

function EmergencyGiftActivity:GetGiftProductInfo(giftIdList)
  local reqMsgMust = MTTDProto.Cmd_Act_EmergencyGift_Trigger_CS()
  reqMsgMust.iActivityId = self:getID()
  reqMsgMust.vGiftId = giftIdList
  RPCS():Act_EmergencyGift_Trigger(reqMsgMust, handler(self, self.OnRefreshPushList))
end

function EmergencyGiftActivity:OnRefreshPushList(data)
  if #data.vNewProduct > 0 then
    if not self.m_pushPackList then
      self.m_pushPackList = {}
    end
    for _, v in pairs(data.vNewProduct) do
      if v then
        local giftInfo = {
          ProductInfo = v,
          GiftInfo = self.m_packListCfg[v.iGiftID]
        }
        self.m_pushPackList[#self.m_pushPackList + 1] = giftInfo
      end
    end
    self:broadcastEvent("eGameEvent_Activity_EmergencyGiftPush", {isPush = true})
  end
end

return EmergencyGiftActivity
