local BaseActivity = require("Base/BaseActivity")
local PersonalRaidActivity = class("PersonalRaidActivity", BaseActivity)

function PersonalRaidActivity.getActivityType(_)
  return MTTD.ActivityType_SoloRaid
end

function PersonalRaidActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgSoloRaid
end

function PersonalRaidActivity.getStatusProto(_)
  return MTTDProto.CmdActSoloRaid_Status
end

function PersonalRaidActivity:OnResetSdpConfig()
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    self.m_iSettleTime = self.m_stSdpConfig.stCommonCfg.iSettleTime
  end
end

function PersonalRaidActivity:OnResetStatusData()
  if not self.m_stStatusData or self.m_stStatusData.iActivityId == self:getID() then
  end
end

function PersonalRaidActivity:checkCondition()
  if not PersonalRaidActivity.super.checkCondition(self) then
    return false
  end
  if not self:IsInActivityTime() then
    return false
  end
  return true
end

function PersonalRaidActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iBeginTime == 0 or self.m_stActivityData.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function PersonalRaidActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

function PersonalRaidActivity:GetPersonalRaidBattleEndTime()
  if not self.m_iSettleTime then
    return 0
  end
  return self.m_iSettleTime
end

function PersonalRaidActivity:GetPersonalRaidEndTime()
  if not self.m_stActivityData.iEndTime then
    return 0
  end
  return self.m_stActivityData.iEndTime
end

return PersonalRaidActivity
