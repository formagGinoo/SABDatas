local BaseActivity = require("Base/BaseActivity")
local StageGiftActivity = class("StageGiftActivity", BaseActivity)

function StageGiftActivity.getActivityType(_)
  return MTTD.ActivityType_LimitChainGift
end

function StageGiftActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgLimitChainGift
end

function StageGiftActivity.getStatusProto(_)
  return MTTDProto.CmdActLimitChainGift_Status
end

function StageGiftActivity:OnResetSdpConfig()
  self.mGiftGroup = {}
  self.m_openID = 0
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg and self.m_stSdpConfig.stCommonCfg.mGiftGroup then
    local list = self.m_stSdpConfig.stCommonCfg.mGiftGroup
    for _, v in pairs(list) do
      self.mGiftGroup[v.iGiftGroupId] = v
    end
  end
end

function StageGiftActivity:getGroupByID(iGiftGroupId)
  return self.mGiftGroup[iGiftGroupId]
end

function StageGiftActivity:GetOpenID()
  self.m_openID = 0
  if self.stGroupInfo and self.stGroupInfo.iGiftGroupId then
    self.m_openID = self.stGroupInfo.iGiftGroupId
    if self.m_openID == 0 then
      self:CheckGroupOpen()
    end
  end
  return self.m_openID
end

function StageGiftActivity:GetOpenGroup()
  if self.stGroupInfo and self.stGroupInfo.iGiftGroupId then
    return self.mGiftGroup[self.stGroupInfo.iGiftGroupId]
  end
end

function StageGiftActivity:CLoseCurGroup()
  local proto = MTTDProto.Cmd_Act_LimitChainGift_CloseGiftGroup_CS()
  proto.iActivityID = self:getID()
  proto.iGiftGroupId = self.stGroupInfo.iGiftGroupId
  RPCS():Act_LimitChainGift_CloseGiftGroup(proto, function(sc, msg)
    self:broadcastEvent("eGameEvent_Activity_PushStageGift")
  end)
end

function StageGiftActivity:OnResetStatusData()
  self.mGiftInfo = {}
  self.stGiftGroupInfo = nil
  if self.m_stStatusData then
    self.stGroupInfo = self.m_stStatusData.stGiftGroupInfo
    self.triggerIDs = self.m_stStatusData.mTriggeredGroup
    if self.stGroupInfo.iGiftGroupId == 0 then
      local disNum = self.m_stStatusData.iLastGiftGroupCloseTime + self.m_stSdpConfig.stCommonCfg.iGiftGroupTriggerInterval - TimeUtil:GetServerTimeS()
      if disNum < 0 then
        self:CheckGroupOpen()
      end
    end
    self:broadcastEvent("eGameEvent_Activity_PushStageGift")
  end
end

function StageGiftActivity:checkCondition()
  if not StageGiftActivity.super.checkCondition(self) then
    return false
  end
  if not self:IsInActivityTime() then
    return false
  end
  return true
end

function StageGiftActivity:IsNeedPushFace()
  if self.stGroupInfo and self.stGroupInfo.iGiftGroupId > 0 then
    local localKey = "StageGiftActivityPush" .. self.m_stStatusData.iActivityId .. self.stGroupInfo.iGiftGroupId
    local hasPush = LocalDataManager:GetIntSimple(localKey, 0)
    if hasPush == 0 then
      LocalDataManager:SetIntSimple(localKey, 1)
      return true
    end
  end
  return false
end

function StageGiftActivity:CheckGroupOpen()
  local curGroupByID = -1
  for k, v in pairs(self.triggerIDs) do
    if k < curGroupByID or curGroupByID == -1 then
      curGroupByID = k
    end
  end
  if 0 < curGroupByID then
    local disNum = self.m_stStatusData.iLastGiftGroupCloseTime + self.m_stSdpConfig.stCommonCfg.iGiftGroupTriggerInterval - TimeUtil:GetServerTimeS()
    if disNum < 0 then
      local msg = MTTDProto.Cmd_Act_LimitChainGift_OpenGiftGroup_CS()
      msg.iActivityID = self:getID()
      msg.iGiftGroupId = curGroupByID
      RPCS():Act_LimitChainGift_OpenGiftGroup(msg, function(sc, msg)
        if sc.bSuccess then
        end
      end)
    end
  end
end

function StageGiftActivity:BuyGiftPackage(config, act)
  local ProductInfo = {
    productId = config.sProductId,
    productSubId = config.iProductSubId,
    iStoreType = MTTDProto.IAPStoreType_ActLimitChainGift,
    productName = "123",
    productDesc = "123"
  }
  local baseStoreBuyParam = MTTDProto.CmdActLimitChainGiftBuyParam()
  baseStoreBuyParam.iActivityId = act:getID()
  baseStoreBuyParam.iGiftGroupId = 1
  baseStoreBuyParam.iGiftGoodsId = config.sProductId
  local storeParam = sdp.pack(baseStoreBuyParam)
  IAPManager:BuyProductByStoreType(ProductInfo, storeParam, function(isSuccess, param1, param2)
    if not isSuccess then
      IAPManager:OnCallbackFail(param1, param2)
      return
    end
    self:broadcastEvent("eGameEvent_Buy_Gift_Success")
  end)
end

function StageGiftActivity:GetGiftGroup()
  return self.mGiftGroup
end

function StageGiftActivity:RqsSetReward(iGiftId, mGridRewardIndex)
  local msg = MTTDProto.Cmd_Act_PickupGift_SetReward_CS()
  msg.iActivityId = self:getID()
  msg.iGiftId = iGiftId
  msg.mGridRewardIndex = mGridRewardIndex
  RPCS():Act_PickupGift_SetReward(msg, function()
  end)
end

function StageGiftActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iBeginTime == 0 or self.m_stActivityData.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function StageGiftActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

return StageGiftActivity
