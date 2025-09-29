local BaseActivity = require("Base/BaseActivity")
local PreviewActivity = class("PreviewActivity", BaseActivity)
local iDaySecond = 86400
local iWeekDay = 7
local iWeekSecond = iDaySecond * iWeekDay

function PreviewActivity.getActivityType(_)
  return MTTD.ActivityType_Calendar
end

function PreviewActivity.getSdpConfigProto(_)
  return MTTDProto.CmdActCfgCalendar
end

function PreviewActivity.getStatusProto(_)
  return MTTDProto.CmdActCalendar_Status
end

function PreviewActivity:OnResetSdpConfig()
  if not self.bIsInit then
    self:addEventListener("eGameEvent_Activity_HallActivityChange", handler(self, self.FormatTimeData))
    self.bIsInit = true
  end
  self:InitData()
  self:FormatTimeData()
end

function PreviewActivity:OnDailyZeroReset()
  self:FormatTimeData()
end

function PreviewActivity:OnResetStatusData()
end

function PreviewActivity:GetAllWeekPreviewList()
  return self.vAllWeekPreviewList or {}
end

function PreviewActivity:checkCondition()
  if not PreviewActivity.super.checkCondition(self) then
    return false
  end
  if not self:isInActivityTime() then
    return false
  end
  return true
end

function PreviewActivity:CheckActivityIsOpen()
  local openFlag = false
  if self:checkCondition() then
    openFlag = true
  end
  return openFlag
end

function PreviewActivity:InitData()
  if self.m_stSdpConfig then
    local stClientCfg = self.m_stSdpConfig.stClientCfg
    local mActStyle = stClientCfg.mActStyle or {}
    self.m_ActType2Style = {}
    for _, stInfo in pairs(mActStyle) do
      self.m_ActType2Style[stInfo.iActType] = stInfo
    end
  end
end

function PreviewActivity:GetUpcomingPreviewList()
  return self.m_stSdpConfig and self.m_stSdpConfig.stClientCfg.mUpcoming or {}
end

function PreviewActivity:FormatTimeData()
  local vActivityList = ActivityManager:GetAllPreviewActivityList()
  local iCurMonday0Clock = TimeUtil:GetMonday0Clock()
  local iMaxEndTime = 0
  for _, activity in ipairs(vActivityList) do
    if iMaxEndTime < activity.m_stActivityData.iEndTime then
      iMaxEndTime = activity.m_stActivityData.iEndTime
    end
  end
  if iMaxEndTime == 0 then
    self.vAllWeekPreviewList = {}
    return
  end
  local iLastMonday0Clock = TimeUtil:GetMonday0Clock(TimeUtil:GetZeroClockTimeSParam(iMaxEndTime))
  self:UpdateAllWeekPreviewList(vActivityList, iCurMonday0Clock, iLastMonday0Clock)
end

function PreviewActivity:UpdateAllWeekPreviewList(vActivityList, iCurMonday0Clock, iLastMonday0Clock)
  local vAllWeekPreviewList = {}
  local iTempTime = iCurMonday0Clock
  while iLastMonday0Clock >= iTempTime do
    local list = {}
    for _, activity in ipairs(vActivityList) do
      if not (activity.m_stActivityData.iBeginTime >= iTempTime + iWeekSecond) and not (iTempTime >= activity.m_stActivityData.iEndTime) and activity.m_stActivityData.iBeginTime ~= 0 and activity.m_stActivityData.iEndTime ~= 0 then
        local stStyle = self.m_ActType2Style[activity:getType()] or self.m_ActType2Style[0] or {}
        local info = {
          activity = activity,
          iWeekMonday0Clock = iTempTime,
          iWeekSunday0Clock = iTempTime + iWeekSecond,
          stStyle = stStyle
        }
        table.insert(list, info)
      end
    end
    if 1 < #list then
      table.sort(list, function(a, b)
        local aOrder = a.stStyle and a.stStyle.iOrder or 0
        local bOrder = b.stStyle and b.stStyle.iOrder or 0
        return aOrder < bOrder
      end)
    end
    local t = {
      iStartTime = iTempTime,
      iEndTime = iTempTime + iWeekSecond,
      vActivityList = list
    }
    table.insert(vAllWeekPreviewList, t)
    iTempTime = iTempTime + iWeekSecond
  end
  self.vAllWeekPreviewList = vAllWeekPreviewList
end

function PreviewActivity:getSubPanelName()
  return ActivityManager.ActivitySubPanelName.ActivitySPName_PreviewActivity
end

return PreviewActivity
