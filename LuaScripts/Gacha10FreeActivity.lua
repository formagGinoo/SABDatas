local BaseActivity = require("Base/BaseActivity")
local Gacha10FreeActivity = class("Gacha10FreeActivity", BaseActivity)

function Gacha10FreeActivity.getActivityType(_)
  return MTTD.ActivityType_GachaFree
end

function Gacha10FreeActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgGachaFree
end

function Gacha10FreeActivity.getStatusProto(_)
  return MTTDProto.CmdActGachaFree_Status
end

function Gacha10FreeActivity:OnResetSdpConfig()
  if not self.m_stSdpConfig or self.m_stSdpConfig.stCommonCfg then
  end
end

function Gacha10FreeActivity:OnResetStatusData()
  if not self.m_stStatusData or self.m_stStatusData.iActivityId == self:getID() then
  end
end

function Gacha10FreeActivity:GetActCommonCfg()
  if self.m_stSdpConfig and self.m_stSdpConfig.stCommonCfg then
    return self.m_stSdpConfig.stCommonCfg
  end
end

function Gacha10FreeActivity:checkCondition()
  if not Gacha10FreeActivity.super.checkCondition(self) then
    return false
  end
  if not self:IsInActivityTime() then
    return false
  end
  local openFlag = UnlockSystemUtil:IsSystemOpen(GlobalConfig.SYSTEM_ID.GachaFree)
  return openFlag
end

function Gacha10FreeActivity:IsInActivityTime()
  if not self.m_stActivityData then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iBeginTime, self.m_stActivityData.iEndTime)
end

function Gacha10FreeActivity:IsInActivityShowTime()
  if not self.m_stActivityData then
    return false
  end
  if self.m_stActivityData.iShowTimeBegin == 0 or self.m_stActivityData.iShowTimeEnd == 0 then
    return false
  end
  return TimeUtil:IsInTime(self.m_stActivityData.iShowTimeBegin, self.m_stActivityData.iShowTimeEnd)
end

function Gacha10FreeActivity:GetActivityEndTime()
  if not self.m_stActivityData.iEndTime then
    return 0
  end
  return self.m_stActivityData.iEndTime
end

return Gacha10FreeActivity
