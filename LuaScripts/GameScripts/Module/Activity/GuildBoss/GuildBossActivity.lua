local BaseActivity = require("Base/BaseActivity")
local GuildBossActivity = class("GuildBossActivity", BaseActivity)

function GuildBossActivity.getActivityType(_)
  return MTTD.ActivityType_AllianceBattle
end

function GuildBossActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgAllianceBattle
end

function GuildBossActivity.getStatusProto(_)
  return MTTDProto.CmdActAllianceBattle_Status
end

function GuildBossActivity:OnResetSdpConfig()
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    self.m_iSettleTime = self.m_stSdpConfig.stCommonCfg.iSettleTime
    self.m_iBattleId = self.m_stSdpConfig.stCommonCfg.iBattleId
  end
end

function GuildBossActivity:OnResetStatusData()
  if not self.m_stStatusData or self.m_stStatusData.iActivityId == self:getID() then
  end
end

function GuildBossActivity:checkCondition()
  if not GuildBossActivity.super.checkCondition(self) then
    return false
  end
  if not self:IsInActivityTime() then
    return false
  end
  return true
end

function GuildBossActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iBeginTime == 0 or self.m_stActivityData.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function GuildBossActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

function GuildBossActivity:GetGuildBossBattleEndTime()
  if not self.m_iSettleTime then
    return 0
  end
  return self.m_iSettleTime
end

function GuildBossActivity:GetGuildBossEndTime()
  if not self.m_stActivityData.iEndTime then
    return 0
  end
  return self.m_stActivityData.iEndTime
end

function GuildBossActivity:GetGuildBossBeginTime()
  if not self.m_stActivityData.iBeginTime then
    return 0
  end
  return self.m_stActivityData.iBeginTime
end

function GuildBossActivity:GetGuildBossId()
  if not self.m_iBattleId then
    return 0
  end
  return self.m_iBattleId
end

return GuildBossActivity
