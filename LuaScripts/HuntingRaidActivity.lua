local BaseActivity = require("Base/BaseActivity")
local HuntingRaidActivity = class("HuntingRaidActivity", BaseActivity)

function HuntingRaidActivity.getActivityType(_)
  return MTTD.ActivityType_Hunting
end

function HuntingRaidActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgHunting
end

function HuntingRaidActivity.getStatusProto(_)
  return MTTDProto.CmdActHunting_Status
end

function HuntingRaidActivity:OnResetSdpConfig()
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    self.mTimeManager = self.m_stSdpConfig.stCommonCfg.mTimeManager
    self.vAllBoss = self.m_stSdpConfig.stCommonCfg.vAllBoss
    self.iRewardTime = self.m_stSdpConfig.stCommonCfg.iRewardTime
  end
end

function HuntingRaidActivity:OnResetStatusData()
  local openRaid = self:IsInActivityShowTime()
  local isOpen = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.HuntingRaid)
  if isOpen and openRaid then
    HuntingRaidManager:ReqEnterGameHuntingRaidGetDataCS(self:getID())
  end
end

function HuntingRaidActivity:checkCondition()
  if not HuntingRaidActivity.super.checkCondition(self) then
    return false
  end
  return true
end

function HuntingRaidActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iBeginTime == 0 or self.iRewardTime == 0 or not self.iRewardTime then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.iRewardTime)
end

function HuntingRaidActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

function HuntingRaidActivity:GetHuntingRaidEndTime()
  if not self.iRewardTime then
    return 0, 0
  end
  local curTime = TimeUtil:GetServerTimeS()
  return self.m_stActivityData.iShowTimeEnd - curTime, self.iRewardTime - curTime
end

function HuntingRaidActivity:GetHuntingRaidBossList()
  if not self.vAllBoss then
    return {}
  end
  return self.vAllBoss
end

function HuntingRaidActivity:CheckBossInShowAndChallengeTime(iBossId)
  local showTime = 0
  local challengeTime = 0
  if not iBossId then
    return showTime, challengeTime
  end
  local curTime = TimeUtil:GetServerTimeS()
  if self.mTimeManager then
    for i, v in pairs(self.mTimeManager) do
      for m, bossId in pairs(v.vBoss) do
        if bossId == iBossId and curTime >= v.iStartTime and curTime < v.iEndTime then
          showTime = v.iEndTime - curTime
          challengeTime = v.iFightEndTime - curTime
        end
      end
    end
  end
  return showTime, challengeTime
end

return HuntingRaidActivity
