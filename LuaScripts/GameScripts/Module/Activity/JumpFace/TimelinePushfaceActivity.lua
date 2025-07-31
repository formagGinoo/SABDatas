local BaseActivity = require("Base/BaseActivity")
local TimelinePushfaceActivity = class("TimelinePushfaceActivity", BaseActivity)

function TimelinePushfaceActivity.getActivityType(_)
  return MTTD.ActivityType_TimelineJump
end

function TimelinePushfaceActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgTimelineJump
end

function TimelinePushfaceActivity.getStatusProto(_)
  return MTTDProto.CmdActTimelineJump_Status
end

function TimelinePushfaceActivity:RequestGetReward(callback)
  local msg = MTTDProto.Cmd_Act_TimelineJump_GetReward_CS()
  msg.iActivityId = self:getID()
  
  local function OnRequestGetRewardSC(sc)
    local vReward = sc.vReward
    if vReward and 0 < #vReward then
      utils.popUpRewardUI(vReward)
    end
    self.m_stStatusData.bIsRewarded = true
    if callback then
      callback(sc)
    end
  end
  
  RPCS():Act_TimelineJump_GetReward(msg, OnRequestGetRewardSC)
end

function TimelinePushfaceActivity:OnResetSdpConfig()
  self.m_clientCfg = {}
  if self.m_stSdpConfig then
    self.m_clientCfg = self.m_stSdpConfig.stClientCfg
  end
end

function TimelinePushfaceActivity:OnResetStatusData()
end

function TimelinePushfaceActivity:GetbIsRewarded()
  if not self.m_stStatusData then
    return false
  end
  return self.m_stStatusData.bIsRewarded or false
end

function TimelinePushfaceActivity:OnPushPanel()
  local id = self:getID()
  if not self:CheckActivityIsOpen() then
    return
  end
  local nextDayResetTime = TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime())
  local bIsNewDay = nextDayResetTime - 1000 > LocalDataManager:GetIntSimple("TimelinePushface_Red_Point" .. id, 0)
  if not self:GetbIsRewarded() and bIsNewDay then
    self:broadcastEvent("eGameEvent_TimelinePushface", {
      activityId = self:getID()
    })
    LocalDataManager:SetIntSimple("TimelinePushface_Red_Point" .. id, nextDayResetTime)
  end
end

function TimelinePushfaceActivity:checkCondition()
  if not TimelinePushfaceActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  return true
end

function TimelinePushfaceActivity:CheckActivityIsOpen()
  local openFlag = false
  if self:checkCondition() then
    openFlag = true
  end
  return openFlag
end

function TimelinePushfaceActivity:GetClientConfig()
  if not self.m_stSdpConfig then
    return {}
  end
  return self.m_stSdpConfig.stClientCfg or {}
end

function TimelinePushfaceActivity:GetCommonConfig()
  if not self.m_stSdpConfig then
    return {}
  end
  return self.m_stSdpConfig.stCommonCfg or {}
end

function TimelinePushfaceActivity:GetJumpPushFacePanelName()
  return "Form_Activity105_PV"
end

return TimelinePushfaceActivity
