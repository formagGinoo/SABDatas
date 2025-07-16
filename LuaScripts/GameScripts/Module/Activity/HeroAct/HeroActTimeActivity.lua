local BaseActivity = require("Base/BaseActivity")
local HeroActTimeActivity = class("HeroActTimeActivity", BaseActivity)

function HeroActTimeActivity.getActivityType(_)
  return MTTD.ActivityType_LamiaTimeManager
end

function HeroActTimeActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgLamiaTimeManager
end

function HeroActTimeActivity.getStatusProto(_)
  return MTTDProto.CmdActLamiaTimeManager_Status
end

function HeroActTimeActivity:OnResetSdpConfig(m_stSdpConfig)
  self.mHeroActTimeCfg = {}
  if m_stSdpConfig and m_stSdpConfig.stCommonCfg and m_stSdpConfig.stCommonCfg.iDisable == 0 then
    self.mHeroActTimeCfg[m_stSdpConfig.stCommonCfg.iLamiaId] = m_stSdpConfig.stCommonCfg
  end
  self:broadcastEvent("eGameEvent_HeroActTimeCfgUpdate")
end

function HeroActTimeActivity:OnResetStatusData()
  if not self.m_stStatusData or self.m_stStatusData.iActivityId == self:getID() then
  end
end

function HeroActTimeActivity:checkCondition()
  if not HeroActTimeActivity.super.checkCondition(self) then
    return false
  end
  if not self:IsInActivityTime() then
    return false
  end
  return true
end

function HeroActTimeActivity:GetHeroActTimeCfgByActID(iLamiaId)
  return self.mHeroActTimeCfg[iLamiaId]
end

function HeroActTimeActivity:GetHeroActTimeCfgList()
  return self.mHeroActTimeCfg
end

function HeroActTimeActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iBeginTime == 0 or self.m_stActivityData.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function HeroActTimeActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

return HeroActTimeActivity
