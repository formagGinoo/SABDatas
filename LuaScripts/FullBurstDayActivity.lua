local BaseActivity = require("Base/BaseActivity")
local FullBurstDayActivity = class("FullBurstDayActivity", BaseActivity)

function FullBurstDayActivity.getActivityType(_)
  return MTTD.ActivityType_FullBurstDay
end

function FullBurstDayActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgFullBurstDay
end

function FullBurstDayActivity.getStatusProto(_)
  return MTTDProto.CmdActFullBurstDay_Status
end

function FullBurstDayActivity:OnResetSdpConfig(m_stSdpConfig)
  self.m_vQuestList = {}
  self.m_clientCfg = {}
  if m_stSdpConfig then
    local vOpenDay = m_stSdpConfig.stCommonCfg.vOpenDay
    local temp = string.split(vOpenDay, ";")
    self.mOpenDays = {}
    if temp then
      for i, v in ipairs(temp) do
        local day = tonumber(v)
        self.mOpenDays[day % 7] = true
      end
    end
  end
  self:broadcastEvent("eGameEvent_Activity_FullBurstDayUpdate")
end

function FullBurstDayActivity:OnResetStatusData()
  self:broadcastEvent("eGameEvent_Activity_FullBurstDayUpdate", {
    iActivityID = self:getID()
  })
end

function FullBurstDayActivity:checkCondition()
  if not FullBurstDayActivity.super.checkCondition(self) then
    return false
  end
  return true
end

function FullBurstDayActivity:CheckActivityIsOpen()
  local openFlag = false
  if self:checkCondition() and self:isInActivityTime() then
    openFlag = true
  end
  return openFlag
end

function FullBurstDayActivity:checkShowRed()
  if not self:CheckActivityIsOpen() then
    return false
  end
  return false
end

function FullBurstDayActivity:IsFullBurstDay()
  if not self:CheckActivityIsOpen() then
    return false
  end
  local timestamp = TimeUtil:GetServerTimeS()
  local iDayTimeOffset = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("DayTimeOffset").m_Value or 0)
  timestamp = timestamp - iDayTimeOffset
  local date = TimeUtil:GetServerDate(timestamp)
  local temp = date.wday - 1
  return self.mOpenDays[temp]
end

return FullBurstDayActivity
