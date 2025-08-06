local BaseActivity = require("Base/BaseActivity")
local ForbidCustomDescMgrActivity = class("ForbidCustomDescMgrActivity", BaseActivity)

function ForbidCustomDescMgrActivity.getActivityType(_)
  return MTTD.ActivityType_ForbidCustomDescManager
end

function ForbidCustomDescMgrActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgForbidCustomDescManager
end

function ForbidCustomDescMgrActivity.getStatusProto(_)
  return MTTDProto.CmdActForbidCustomDescManager_Status
end

function ForbidCustomDescMgrActivity:OnResetSdpConfig(m_stSdpConfig)
  self.m_stCommonCfg = m_stSdpConfig.stCommonCfg
end

function ForbidCustomDescMgrActivity:OnResetStatusData()
end

function ForbidCustomDescMgrActivity:checkCondition()
  return true
end

function ForbidCustomDescMgrActivity:CheckActivityIsOpen()
  return true
end

function ForbidCustomDescMgrActivity:GetShowMessageStr(errorCode)
  local showMessageCfg = ConfigManager:GetConfigInsByName("ShowMessage")
  if showMessageCfg then
    local element = showMessageCfg:GetValue_ByID(errorCode)
    if element and element.m_mMessage then
      return element.m_mMessage
    end
  end
end

function ForbidCustomDescMgrActivity:IsInLimitTime()
  if not self.m_stCommonCfg then
    return
  end
  local curTimer = TimeUtil:GetServerTimeS()
  local forbidCustomDescEmergencyMap = self.m_stCommonCfg.mForbidCustomDescEmergency
  if forbidCustomDescEmergencyMap and next(forbidCustomDescEmergencyMap) then
    for i, v in pairs(forbidCustomDescEmergencyMap) do
      local startTime = v.begin_time or 0
      local endTime = v.end_time or 0
      if curTimer >= startTime and curTimer < endTime then
        return true, self:GetShowMessageStr(6652)
      end
    end
  end
  local forbidCustomDescMap = self.m_stCommonCfg.mForbidCustomDesc
  if forbidCustomDescMap and next(forbidCustomDescMap) then
    local curServerData = TimeUtil:GetServerDate(curTimer)
    local curYearNum = curServerData.year
    for i, v in pairs(forbidCustomDescMap) do
      local startTime = v.begin_time or 0
      local startTimeStr = curYearNum .. "-" .. startTime
      local startTimer = TimeUtil:TimeStringToTimeSec2(startTimeStr)
      local endTime = v.end_time or 0
      local endTimeStr = curYearNum .. "-" .. endTime
      local endTimer = TimeUtil:TimeStringToTimeSec2(endTimeStr)
      if curTimer >= startTimer and curTimer < endTimer then
        return true, self:GetShowMessageStr(6651)
      end
    end
  end
end

return ForbidCustomDescMgrActivity
