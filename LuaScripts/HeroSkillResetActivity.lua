local BaseActivity = require("Base/BaseActivity")
local HeroSkillResetActivity = class("HeroSkillResetActivity", BaseActivity)

function HeroSkillResetActivity.getActivityType(_)
  return MTTD.ActivityType_HeroSkillReset
end

function HeroSkillResetActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgHeroSkillReset
end

function HeroSkillResetActivity.getStatusProto(_)
  return MTTDProto.CmdActHeroSkillReset_Status
end

function HeroSkillResetActivity:OnResetSdpConfig()
  if not self.m_stSdpConfig or self.m_stSdpConfig.stCommonCfg then
  end
end

function HeroSkillResetActivity:OnResetStatusData()
  if not self.m_stStatusData or self.m_stStatusData.iActivityId == self:getID() then
  end
end

function HeroSkillResetActivity:checkCondition()
  if not HeroSkillResetActivity.super.checkCondition(self) then
    return false
  end
  if not self:IsInActivityTime() then
    return false
  end
  return true
end

function HeroSkillResetActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iBeginTime == 0 or self.m_stActivityData.iEndTime == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function HeroSkillResetActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

function HeroSkillResetActivity:GetActivityEndTime()
  if not self.m_stActivityData.iEndTime then
    return 0
  end
  return self.m_stActivityData.iEndTime
end

return HeroSkillResetActivity
