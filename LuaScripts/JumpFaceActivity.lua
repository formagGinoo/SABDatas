local BaseActivity = require("Base/BaseActivity")
local JumpFaceActivity = class("JumpFaceActivity", BaseActivity)
local JumpAndReserveType = {
  Reserve = 1,
  Jump = 2,
  JumpAndReserve = 3
}
local subPanelData = {
  [25004] = {
    subPanelName = "GachaLamiaPushFaceSubPanel",
    Priority = 1
  },
  [25005] = {
    subPanelName = "GachaDalCaroPushFaceSubPanel",
    Priority = 1
  },
  [2702] = {
    subPanelName = "ActivityBoqinaFaceSubPanel",
    Priority = 3
  },
  [25] = {
    subPanelName = "ActivityPersonalRaidSubPanel",
    Priority = 2
  },
  [27] = {
    subPanelName = "ActivityHuntNightSubPanel",
    Priority = 2
  }
}

function JumpFaceActivity.getActivityType(_)
  return MTTD.ActivityType_GachaJump
end

function JumpFaceActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgGachaJump
end

function JumpFaceActivity.getStatusProto(_)
  return MTTDProto.CmdActGachaJump_Status
end

function JumpFaceActivity:OnPushPanel()
  if self:checkShowRed() then
    self:broadcastEvent("eGameEvent_JumpFaceActivity", {
      activityId = self:getID()
    })
    ActivityManager:SetShowRedCurrentLogin(self:getID())
  end
end

function JumpFaceActivity:OnResetSdpConfig()
  self.m_reserveRewardList = {}
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg.sOrderReward then
    for iIndex, stSignInfo in pairs(self.m_stSdpConfig.stCommonCfg.sOrderReward) do
      local vRewardParamsTotal = string.split(stSignInfo, ";")
      stSignInfo.stRewardInfo = {}
      for i = 1, #vRewardParamsTotal do
        local vRewardParams = string.split(vRewardParamsTotal[i], ",")
        stSignInfo.stRewardInfo[i] = {
          iID = tonumber(vRewardParams[1]),
          iNum = tonumber(vRewardParams[2])
        }
      end
      self.m_reserveRewardList[checknumber(iIndex)] = stSignInfo
    end
  end
end

function JumpFaceActivity:OnGetActData()
  return self.m_stActivityData
end

function JumpFaceActivity:checkCondition()
  if not JumpFaceActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  return true
end

function JumpFaceActivity:checkShowRed()
  if self:checkCondition() then
    local statue = self:GetActStatueInCurTime()
    if statue == ActivityManager.ActPushFaceStatue.NoReserve then
      return ActivityManager:CanShowRedCurrentLogin(self:getID())
    end
    if statue == ActivityManager.ActPushFaceStatue.Reserve then
      return false
    end
    if statue == ActivityManager.ActPushFaceStatue.Jump and ActivityManager:CanShowRedCurrentLogin(self:getID()) and not self:IsGetReserveState() then
      return true
    end
  end
  return false
end

function JumpFaceActivity:GetActReserveReward()
  return self.m_reserveRewardList
end

function JumpFaceActivity:GetActReserveRewardState()
  return LocalDataManager:GetIntSimple("ActPushFace" .. self:getID(), ActivityManager.ActPushFaceStatue.NoReserve)
end

function JumpFaceActivity:SetActReserveRewardState(reserveStatue)
  LocalDataManager:SetIntSimple("ActPushFace" .. self:getID(), reserveStatue)
end

function JumpFaceActivity:GetActivitySubType()
  if self:GetCommonCfg() then
    local commonCfg = self:GetCommonCfg()
    if commonCfg then
      return commonCfg.iUiType
    end
  end
end

function JumpFaceActivity:GetActStatueInCurTime()
  if self:GetActivitySubType() == JumpAndReserveType.JumpAndReserve then
    if TimeUtil:IsInTime(self:GetCommonCfg().sOrderBeginTime, self:GetCommonCfg().sOrderEndTime) then
      if self:GetActReserveRewardState() == ActivityManager.ActPushFaceStatue.Reserve then
        return ActivityManager.ActPushFaceStatue.Reserve
      else
        return ActivityManager.ActPushFaceStatue.NoReserve
      end
    else
      return ActivityManager.ActPushFaceStatue.Jump
    end
  end
  if self:GetActivitySubType() == JumpAndReserveType.Jump then
    return ActivityManager.ActPushFaceStatue.Jump
  end
  if self:GetActivitySubType() == JumpAndReserveType.Reserve then
    if self:GetActReserveRewardState() == ActivityManager.ActPushFaceStatue.Reserve then
      return ActivityManager.ActPushFaceStatue.Reserve
    else
      return ActivityManager.ActPushFaceStatue.NoReserve
    end
  end
end

function JumpFaceActivity:IsGetReserveState()
  return self.m_stStatusData.bRecivedOrderAward or false
end

function JumpFaceActivity:GetCommonCfg()
  return self.m_stSdpConfig.stCommonCfg
end

function JumpFaceActivity:IsCanGetReward()
  local reward = self:GetActReserveReward()
  if reward and 1 <= #reward and self:GetActReserveReward() and self:GetActStatueInCurTime() == ActivityManager.ActPushFaceStatue.Jump and not self:IsGetReserveState() and TimeUtil:GetServerTimeS() > self:GetCommonCfg().sOrderEndTime then
    return true
  end
  return false
end

function JumpFaceActivity:RequestReserveReward()
  local reqMsg = MTTDProto.Cmd_Act_GachaJump_Order_CS()
  reqMsg.iActivityId = self:getID()
  RPCS():Act_GachaJump_Order(reqMsg, function(sc, msg)
    self.m_stStatusData.bRecivedOrderAward = sc.bRecivedOrderAward
    self:broadcastEvent("eGameEvent_Activity_PushFaceReserve", {
      iActivityID = self:getID(),
      vReward = sc.sOrderReward
    })
  end)
end

function JumpFaceActivity:OnGetClientConfig()
  return self.m_stSdpConfig.stClientCfg
end

function JumpFaceActivity:GetJumpPushFacePanelName()
  return "Form_ActivityFaceMain"
end

function JumpFaceActivity:GetJumpPushFaceSubPanelName()
  local subData = subPanelData[tonumber(self:OnGetClientConfig().iJumpId)]
  if subData then
    return subData.subPanelName
  end
end

function JumpFaceActivity:GetJumpPushFaceSubPanelPriority()
  local subData = subPanelData[tonumber(self:OnGetClientConfig().iJumpId)]
  if subData then
    return subData.Priority
  end
end

function JumpFaceActivity:GetReserverDownloadActivityID()
  local iActivityMainInfoID
  local iJumpID = self:OnGetClientConfig().iJumpId
  local vActivityMainInfoData = ConfigManager:GetConfigInsByName("ActivityMainInfo"):GetAll()
  for _, stActivityMainInfo in pairs(vActivityMainInfoData) do
    if stActivityMainInfo.m_GachaJumpID[0] == iJumpID then
      iActivityMainInfoID = stActivityMainInfo.m_ActivityID
      break
    end
  end
  return iActivityMainInfoID
end

function JumpFaceActivity:ReserveDownload()
  local iActivityMainInfoID = self:GetReserverDownloadActivityID()
  if iActivityMainInfoID == nil then
    return
  end
  DownloadManager:ReserveDownloadByActivityID(iActivityMainInfoID)
end

function JumpFaceActivity:OnDispose()
  PushFaceManager:RemoveShowPopPanelList(UIDefines.ID_FORM_ACTIVITYFACEMAIN, {
    activityId = self:getID()
  })
end

return JumpFaceActivity
