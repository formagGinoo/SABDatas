local BaseActivity = require("Base/BaseActivity")
local ConsumeRewardActivity = class("ConsumeRewardActivity", BaseActivity)

function ConsumeRewardActivity.getActivityType(_)
  return MTTD.ActivityType_ConsumeReward
end

function ConsumeRewardActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgConsumeReward
end

function ConsumeRewardActivity.getStatusProto(_)
  return MTTDProto.CmdActConsumeReward_Status
end

function ConsumeRewardActivity:OnResetSdpConfig()
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    self.m_pointItemId = self.m_stSdpConfig.stCommonCfg.iPointItem
    self.m_tipsId = self.m_stSdpConfig.stCommonCfg.iPopId
    self.m_rewardList = self.m_stSdpConfig.stCommonCfg.mPointReward
    self.m_productsListInfo = self.m_stSdpConfig.stCommonCfg.mProducts
  end
end

function ConsumeRewardActivity:OnResetStatusData()
  self.m_takenRewardList = self.m_stStatusData.vTakenReward
  self.m_pointNum = self.m_stStatusData.iPoint or 0
end

function ConsumeRewardActivity:checkCondition()
  if not ConsumeRewardActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  return true
end

function ConsumeRewardActivity:GetPointItemId()
  return self.m_pointItemId or -1
end

function ConsumeRewardActivity:checkShowRed()
  if not self:checkCondition() then
    return false
  end
  if not self:CheckHasRewardGet() then
    return false
  end
  return true
end

function ConsumeRewardActivity:CheckHasRewardGet()
  local curPoint = self:GetCurPoint()
  for k, v in pairs(self:GetRewardList()) do
    if curPoint >= v.iNeedPoint and not self:CheckPointRewardIsGet(v.iNeedPoint) then
      return true
    end
  end
  return false
end

function ConsumeRewardActivity:CheckPointRewardIsGet(point)
  local takenPoints = self:GetTakenRewardList()
  for k, v in pairs(takenPoints) do
    if v == point then
      return true
    end
  end
  return false
end

function ConsumeRewardActivity:GetTipsId()
  return self.m_tipsId
end

function ConsumeRewardActivity:GetTakenRewardList()
  return self.m_takenRewardList
end

function ConsumeRewardActivity:GetRewardList()
  local rewardList = {}
  if self.m_rewardList then
    for k, _ in pairs(self.m_rewardList) do
      table.insert(rewardList, k)
    end
  end
  table.sort(rewardList, function(a, b)
    if a ~= b then
      return a < b
    end
  end)
  local showDataList = {}
  for k, _ in ipairs(rewardList) do
    table.insert(showDataList, self.m_rewardList[rewardList[k]])
  end
  return showDataList
end

function ConsumeRewardActivity:GetCurPoint()
  if self:GetPointItemId() then
    return self.m_pointNum or 0
  end
  return 0
end

function ConsumeRewardActivity:GetProductPointList()
  return self.m_productsListInfo
end

function ConsumeRewardActivity:GetProductPointInfo(sProductId)
  if self.m_productsListInfo then
    for k, v in pairs(self.m_productsListInfo) do
      if v.sProductId and v.sProductId == sProductId then
        return v.iPoint
      end
    end
  end
end

function ConsumeRewardActivity:RequestRewardCS(fc)
  local reqMsg = MTTDProto.Cmd_Act_ConsumeReward_TakeReward_CS()
  reqMsg.iActivityId = self:getID()
  RPCS():Act_ConsumeReward_TakeReward(reqMsg, function(sc, msg)
    self.m_takenRewardList = sc.vTakenReward
    utils.popUpRewardUI(sc.vShowReward, function()
      self:broadcastEvent("eGameEvent_Activity_ChargeRebateReward", {
        iActivityID = self:getID()
      })
      if fc then
        fc()
      end
    end)
  end)
end

function ConsumeRewardActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_ConsumeRewardActivity
end

return ConsumeRewardActivity
