TimeUtil = {
  m_serverTime = nil,
  m_setServerTimeSceneTime = nil,
  m_serverTimeGmtOff = nil
}
local CSTime = CS.UnityEngine.Time
local OneSecondOfMS = 1000
local __oneDayOfHour = 24
local __oneDayOfSecond = 86400
local __oneHourOfSecond = 3600
local __oneHourOfMinute = 60
local __oneMinuteOfSecond = 60

function TimeUtil:SetServerTime(serverTime)
  log.info("TimeUtil SetServerTime serverTime: ", serverTime)
  if not serverTime then
    return
  end
  self.m_serverTime = serverTime
  self.m_setServerTimeSceneTime = CSTime.realtimeSinceStartup
end

function TimeUtil:GetServerTimeMS()
  if self.m_setServerTimeSceneTime == nil then
    return 0
  end
  local overTime = math.floor((CSTime.realtimeSinceStartup - self.m_setServerTimeSceneTime) * OneSecondOfMS)
  return self.m_serverTime + overTime
end

function TimeUtil:GetServerTimeS()
  return math.floor(self:GetServerTimeMS() / OneSecondOfMS)
end

function TimeUtil:SetServerTimeGmtOff(iTimeGmtOff)
  self.m_serverTimeGmtOff = iTimeGmtOff
end

function TimeUtil:GetServerTimeGmtOff()
  return self.m_serverTimeGmtOff or 0
end

function TimeUtil:GetServerTimeGmtOffH()
  return self:GetServerTimeGmtOff() / __oneHourOfSecond
end

function TimeUtil:GetClientTimeGmtOff()
  local now = os.time()
  local nowDate = os.date("!*t", now)
  local nowDate1 = os.date("*t", now)
  nowDate.isdst = nowDate1.isdst
  return os.difftime(now, os.time(nowDate))
end

function TimeUtil:GetDiffTimeGmtOff()
  return self:GetServerTimeGmtOff() - self:GetClientTimeGmtOff()
end

function TimeUtil:ClearTimer()
  if self.m_iTimerHandlerCommonResetClock ~= nil then
    TimeService:KillTimer(self.m_iTimerHandlerCommonResetClock)
    self.m_iTimerHandlerCommonResetClock = nil
  end
  if self.m_iTimerHandlerZeroClock ~= nil then
    TimeService:KillTimer(self.m_iTimerHandlerZeroClock)
    self.m_iTimerHandlerZeroClock = nil
  end
end

function TimeUtil:GetRandomDailyDelay()
  math.newrandomseed()
  return math.random(2, 10)
end

function TimeUtil:InitTimer()
  self:ClearTimer()
  local iServerTime = TimeUtil:GetServerTimeS()
  
  local function OnCommonResetClockTimer()
    self.m_iTimerHandlerCommonResetClock = TimeService:SetTimer(86400, 1, OnCommonResetClockTimer)
    GameManager:dailyReset()
  end
  
  local iNextTime = TimeUtil:GetNextResetTime(TimeUtil:GetCommonResetTime())
  self.m_iTimerHandlerCommonResetClock = TimeService:SetTimer(iNextTime - iServerTime + TimeUtil:GetRandomDailyDelay(), 1, OnCommonResetClockTimer)
  
  local function OnZeroClockTimer()
    self.m_iTimerHandlerZeroClock = TimeService:SetTimer(86400, 1, OnZeroClockTimer)
    local reqMsg = MTTDProto.Cmd_Act_DayChangeZero_CS()
    RPCS():Act_DayChangeZero(reqMsg, function(sc, msg)
      GameManager:dailyZeroReset()
    end)
  end
  
  iNextTime = TimeUtil:GetNextResetTime(TimeUtil:SecondsToFourUnit(0))
  self.m_iTimerHandlerZeroClock = TimeService:SetTimer(iNextTime - iServerTime + 2, 1, OnZeroClockTimer)
end

function TimeUtil:IsInTime(iBeginTime, iEndTime)
  if iBeginTime == 0 and iEndTime == 0 then
    return true
  end
  local serverTime = self:GetServerTimeS()
  if iBeginTime ~= 0 then
    if iBeginTime <= serverTime then
      if iEndTime == 0 then
        return true
      elseif iEndTime >= serverTime then
        return true
      else
        return false
      end
    else
      return false
    end
  else
    return true
  end
end

function TimeUtil:SecondsToFourUnit(s)
  return {
    day = math.floor(s / __oneDayOfSecond),
    hour = math.floor(s / __oneHourOfSecond) % __oneDayOfHour,
    min = math.floor(s / __oneMinuteOfSecond) % __oneHourOfMinute,
    sec = s % __oneMinuteOfSecond
  }
end

function TimeUtil:TimeTableToOnlyTopDigitStr(timeTb)
  local timeStr = ""
  local suffixStr = ""
  if timeTb.day > 0 then
    timeStr = timeTb.day
    suffixStr = self:GetCommonCountDownDayStr()
  elseif 0 < timeTb.hour then
    timeStr = timeTb.hour
    suffixStr = self:GetCommonCountDownHourStr()
  elseif 0 < timeTb.min then
    timeStr = timeTb.min
    suffixStr = self:GetCommonCountDownMinuteStr()
  elseif 0 < timeTb.sec then
    timeStr = timeTb.sec
    suffixStr = self:GetCommonCountDownSecondStr()
  end
  return string.CS_Format(suffixStr, timeStr)
end

function TimeUtil:TimeTableToOnlyTopDigitStrOnlyToMin(timeTb)
  local timeStr = ""
  local suffixStr = ""
  if timeTb.day > 0 then
    timeStr = timeTb.day
    suffixStr = self:GetCommonCountDownDayStr()
  elseif 0 < timeTb.hour then
    timeStr = timeTb.hour
    suffixStr = self:GetCommonCountDownHourStr()
  elseif 0 < timeTb.min then
    timeStr = timeTb.min
    suffixStr = self:GetCommonCountDownMinuteStr()
  elseif 0 < timeTb.sec then
    timeStr = timeTb.sec
    suffixStr = self:GetCommonCountDownSecondStr()
  end
  return string.CS_Format(suffixStr, timeStr)
end

function TimeUtil:TimeTableToFormatStr(timeTb)
  local str = ""
  if timeTb.day > 0 then
    local dayFormatStr = self:GetCommonCountDownDayStr()
    str = str .. string.CS_Format(dayFormatStr, timeTb.day)
  end
  if 0 < timeTb.hour then
    local hourFormatStr = self:GetCommonCountDownHourStr()
    str = str .. string.CS_Format(hourFormatStr, timeTb.hour)
  end
  if 0 < timeTb.min then
    local minFormatStr = self:GetCommonCountDownMinuteStr()
    str = str .. string.CS_Format(minFormatStr, timeTb.min)
  end
  if 0 < timeTb.sec then
    local secFormatStr = self:GetCommonCountDownSecondStr()
    str = str .. string.CS_Format(secFormatStr, timeTb.sec)
  end
  return str
end

function TimeUtil:TimeTableToFormatStrOnlyToMin(timeTb)
  local str = ""
  if timeTb.day > 0 then
    local dayFormatStr = self:GetCommonCountDownDayStr()
    str = str .. string.CS_Format(dayFormatStr, timeTb.day)
  end
  if 0 < timeTb.hour then
    local hourFormatStr = self:GetCommonCountDownHourStr()
    str = str .. string.CS_Format(hourFormatStr, timeTb.hour)
  end
  if 0 < timeTb.min then
    local minFormatStr = self:GetCommonCountDownMinuteStr()
    str = str .. string.CS_Format(minFormatStr, timeTb.min)
  end
  return str
end

function TimeUtil:TimeTableToPvpStr(timeTb)
  local timeStr = ""
  local suffixStr = ""
  if timeTb.day > 0 then
    timeStr = timeTb.day
    suffixStr = ConfigManager:GetCommonTextById(100025)
  elseif 0 < timeTb.hour then
    timeStr = timeTb.hour
    suffixStr = ConfigManager:GetCommonTextById(100024)
  elseif 0 < timeTb.min then
    timeStr = timeTb.min
    suffixStr = ConfigManager:GetCommonTextById(100023)
  elseif 0 < timeTb.sec then
    timeStr = timeTb.sec
    suffixStr = nil
  end
  if suffixStr == nil then
    return ConfigManager:GetCommonTextById(100022)
  end
  return string.format(suffixStr, timeStr)
end

function TimeUtil:SecondsToFormatStr(s, onlyTopDigit)
  local timeTb = self:SecondsToFourUnit(s)
  return onlyTopDigit and self:TimeTableToOnlyTopDigitStr(timeTb) or TimeUtil:TimeTableToFormatStr(timeTb)
end

function TimeUtil:SecondsToFormatStrOnlyToMin(s, onlyTopDigit)
  local timeTb = self:SecondsToFourUnit(s)
  return onlyTopDigit and self:TimeTableToOnlyTopDigitStrOnlyToMin(timeTb) or TimeUtil:TimeTableToFormatStrOnlyToMin(timeTb)
end

function TimeUtil:SecondsToFormatStrPvp(s)
  local timeTb = self:SecondsToFourUnit(s)
  return self:TimeTableToPvpStr(timeTb)
end

function TimeUtil:TimeTableToFormatStrDHOrHMS(timeTb)
  local sHour
  if timeTb.hour < 10 then
    sHour = "0" .. timeTb.hour
  else
    sHour = timeTb.hour
  end
  local sMin
  if 10 > timeTb.min then
    sMin = "0" .. timeTb.min
  else
    sMin = timeTb.min
  end
  local sSec = string.format("%02d", math.floor(timeTb.sec))
  if timeTb.day > 0 then
    local dayFormatStr = self:GetCommonCountDownDayStr()
    local hourFormatStr = self:GetCommonCountDownHourStr()
    return string.CS_Format(dayFormatStr, timeTb.day) .. " " .. string.CS_Format(hourFormatStr, sHour)
  else
    return sHour .. ":" .. sMin .. ":" .. sSec
  end
end

function TimeUtil:SecondsToFormatStrDHOrHMS(s)
  local timeTb = self:SecondsToFourUnit(s)
  return self:TimeTableToFormatStrDHOrHMS(timeTb)
end

function TimeUtil:TimeTableToFormatCNStr(timeTb)
  local sHour
  if timeTb.hour < 10 then
    sHour = "0" .. timeTb.hour
  else
    sHour = timeTb.hour
  end
  local sMin
  if 10 > timeTb.min then
    sMin = "0" .. timeTb.min
  else
    sMin = timeTb.min
  end
  local sSec = string.format("%02d", math.floor(timeTb.sec))
  local day_str = self:GetCommonCountDownDayStr()
  local hour_str = self:GetCommonCountDownHourStr()
  local min_str = self:GetCommonCountDownMinuteStr()
  local sec_str = self:GetCommonCountDownSecondStr()
  if timeTb.day > 0 then
    return string.gsubNumberReplace(day_str, timeTb.day) .. " " .. string.gsubNumberReplace(hour_str, sHour)
  else
    return string.gsubNumberReplace(hour_str, sHour) .. " " .. string.gsubNumberReplace(min_str, sMin) .. " " .. string.gsubNumberReplace(sec_str, sSec)
  end
end

function TimeUtil:TimeTableToFormatCNStrMax(seconds)
  local days = math.floor(seconds / 86400)
  seconds = seconds % 86400
  local hours = math.floor(seconds / 3600)
  seconds = seconds % 3600
  local minutes = math.floor(seconds / 60)
  local secs = seconds % 60
  local day_str = self:GetCommonCountDownDayStr()
  local hour_str = self:GetCommonCountDownHourStr()
  local min_str = self:GetCommonCountDownMinuteStr()
  local sec_str = self:GetCommonCountDownSecondStr()
  if 0 <= seconds then
    return string.gsubNumberReplace(day_str, days) .. " " .. string.gsubNumberReplace(hour_str, hours) .. " " .. string.gsubNumberReplace(min_str, minutes) .. " " .. string.gsubNumberReplace(sec_str, secs)
  else
    return string.gsubNumberReplace(0, days) .. " " .. string.gsubNumberReplace(0, hours) .. " " .. string.gsubNumberReplace(0, minutes) .. " " .. string.gsubNumberReplace(0, secs)
  end
end

function TimeUtil:SecondsToFormatCNStr(s)
  local timeTb = self:SecondsToFourUnit(s)
  return self:TimeTableToFormatCNStr(timeTb)
end

function TimeUtil:GetServerDate(serverTime)
  local time_tmp = serverTime + self:GetDiffTimeGmtOff()
  local date = os.date("*t", time_tmp)
  return date
end

function TimeUtil:GetServerTimeWeekDay()
  local date = os.date("!*t", self:GetServerTimeS() + self:GetDiffTimeGmtOff())
  return date.wday
end

function TimeUtil:GetServerTimeWeekDayHaveCommonOffset()
  local serverTimeS = self:GetServerTimeS() + self:GetDiffTimeGmtOff()
  local commonOffsetSecond = self:GetCommonResetTimeSecond()
  local timerNum = serverTimeS - commonOffsetSecond
  local curW = tonumber(os.date("%w", timerNum))
  if curW == 0 then
    curW = 7
  end
  return curW
end

function TimeUtil:GetZeroClockTimeS()
  return self:GetZeroClockTimeSParam(self:GetServerTimeS())
end

function TimeUtil:GetZeroClockTimeSParam(iTime)
  if iTime == nil then
    iTime = self:GetServerTimeS()
  end
  local date = os.date("*t", iTime)
  local isdst = date.isdst
  date = os.date("!*t", iTime + self:GetServerTimeGmtOff())
  date.hour = 0
  date.min = 0
  date.sec = 0
  local timeDiff = self:GetDiffTimeGmtOff()
  local iTimestamp = os.time(date) - timeDiff - (isdst and 3600 or 0)
  if iTime < iTimestamp then
    iTimestamp = iTimestamp - 86400
  end
  return iTimestamp
end

function TimeUtil:GetTimeFromServerDate(date)
  date.isdst = os.date("*t").isdst
  return os.time(date) - self:GetDiffTimeGmtOff()
end

function TimeUtil:GetTimeFromServerDayTime(dayTime, bNextDay)
  local now = self:GetServerTimeS()
  if bNextDay ~= nil and bNextDay then
    now = now + 86400
  end
  local nowSvrDate = self:GetServerDate(now)
  nowSvrDate.hour = dayTime.hour
  nowSvrDate.min = dayTime.min
  nowSvrDate.sec = dayTime.sec
  return self:GetTimeFromServerDate(nowSvrDate)
end

function TimeUtil:GetCommonResetTime()
  if self.m_tCommonResetTime == nil then
    local iDayTimeOffset = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("DayTimeOffset").m_Value or 0)
    self.m_tCommonResetTime = self:SecondsToFourUnit(iDayTimeOffset)
  end
  return self.m_tCommonResetTime
end

function TimeUtil:SetCommonResetTime(resetTime)
  if not resetTime then
    return
  end
  self.m_tCommonResetTime = resetTime
end

function TimeUtil:GetCommonResetTimeSecond()
  if self.m_iCommonResetTimeSecond == nil then
    self.m_iCommonResetTimeSecond = tonumber(ConfigManager:GetConfigInsByName("GlobalSettings"):GetValue_ByName("DayTimeOffset").m_Value or 0)
  end
  return self.m_iCommonResetTimeSecond
end

function TimeUtil:SetCommonResetTimeSecond(resetTimeS)
  if not resetTimeS then
    return
  end
  self.m_iCommonResetTimeSecond = resetTimeS
end

function TimeUtil:GetSpecifiedDateResetTime(iTime, nextDay)
  local date = os.date("!*t", iTime + self:GetServerTimeGmtOff())
  local resetTime = self:GetCommonResetTime()
  date.hour = resetTime.hour
  date.min = resetTime.min
  date.sec = resetTime.sec
  local timeDiff = self:GetDiffTimeGmtOff()
  local iTimestamp = os.time(date)
  local targetDate = os.date("*t", iTimestamp)
  iTimestamp = iTimestamp - (targetDate.isdst and 3600 or 0)
  iTimestamp = iTimestamp - timeDiff
  if iTime < iTimestamp then
    iTimestamp = iTimestamp - 86400
  end
  if nextDay then
    iTimestamp = iTimestamp + 86400
  end
  return iTimestamp
end

function TimeUtil:GetToDayResetTime(configTime)
  return self:GetNextResetTime(configTime) - __oneDayOfSecond
end

function TimeUtil:GetServerToDayCommonResetTime()
  return self:GetToDayResetTime(self:GetCommonResetTime())
end

function TimeUtil:CheckTimeIsToDay(time)
  return time > TimeUtil:GetServerToDayCommonResetTime()
end

function TimeUtil:GetNextResetTime(configTime)
  local serverTime = self:GetServerTimeS()
  local serverConfigTime = self:GetTimeFromServerDayTime(configTime)
  if serverTime > serverConfigTime then
    serverConfigTime = self:GetTimeFromServerDayTime(configTime, true)
  end
  return serverConfigTime
end

function TimeUtil:GetServerNextCommonResetTime()
  return self:GetNextResetTime(self:GetCommonResetTime())
end

function TimeUtil:GetNextWeekResetTime()
  local resetTime = self:GetServerNextCommonResetTime()
  local current_day_of_week = self:GetServerTimeWeekDayHaveCommonOffset()
  local time = (7 - current_day_of_week) * 86400 + resetTime
  return time
end

function TimeUtil:GetNextMonthResetTime()
  local commonResetTime = self:GetCommonResetTimeSecond()
  local hour = math.floor(commonResetTime / __oneHourOfSecond)
  local seconds = commonResetTime % __oneHourOfSecond
  local minutes = math.floor(seconds / 60)
  local serverTime = TimeUtil:GetServerTimeS() - commonResetTime
  local date = self:GetServerDate(serverTime)
  local nextMonth = tonumber(date.month) + 1
  local nextYear = tonumber(date.year)
  if 12 < nextMonth then
    nextMonth = 1
    nextYear = nextYear + 1
  end
  local next_month_timestamp = os.time({
    year = nextYear,
    month = nextMonth,
    day = 1,
    hour = tonumber(hour),
    min = tonumber(minutes),
    sec = 0
  })
  return next_month_timestamp - self:GetDiffTimeGmtOff()
end

function TimeUtil:CompareDayTime(date1, date2)
  local temp1 = date1
  local temp2 = date2
  temp1.year = temp2.year
  temp1.month = temp2.month
  temp1.day = temp2.day
  return os.time(temp1) - os.time(temp2)
end

function TimeUtil:GetPassedServerDay(iBeginTime)
  if iBeginTime == nil or type(iBeginTime) ~= "number" then
    return 0
  end
  local nextFreshtime = self:GetITimeNextResetDay(iBeginTime)
  local iCurTime = self:GetServerTimeS()
  local time = iCurTime - nextFreshtime
  if time < 0 then
    return 1
  end
  local days = math.floor(time / 86400) + 2
  return days
end

function TimeUtil.getUTCTime(time)
  return os.time(os.date("!*t", math.ceil(time or os.time())))
end

function TimeUtil:getLocalTimeZone()
  local now = os.time()
  local difftime = os.difftime(now, TimeUtil:getUTCTime())
  return difftime
end

function TimeUtil:IsCurDayTime(time)
  if not time then
    return
  end
  local tCommonResetTime = self:GetCommonResetTime()
  local iTimeOffset = tCommonResetTime.hour * 3600 + tCommonResetTime.min * 60 + tCommonResetTime.sec
  local server_time_zone = tonumber(TimeUtil:GetServerTimeGmtOff())
  local iServerTime = self:GetServerTimeS() - iTimeOffset + server_time_zone
  local iCheckTime = time - iTimeOffset + server_time_zone
  local iServerDay = math.floor(iServerTime / __oneDayOfSecond)
  local iCheckDay = math.floor(iCheckTime / __oneDayOfSecond)
  return iServerDay == iCheckDay
end

function TimeUtil:ServerTimerToServerString(timeSec)
  if not timeSec then
    return
  end
  return os.date("%Y/%m/%d %H:%M:%S", timeSec)
end

function TimeUtil:ServerTimerToServerString2(timeSec)
  if not timeSec then
    return
  end
  local server_time_zone = TimeUtil:GetServerTimeGmtOff()
  local local_time_zone = TimeUtil:GetClientTimeGmtOff()
  timeSec = timeSec - local_time_zone + server_time_zone
  return os.date("%Y/%m/%d", timeSec)
end

function TimeUtil:TimerToString(timeSec)
  if not timeSec then
    return
  end
  local server_time_zone = TimeUtil:GetServerTimeGmtOff()
  local local_time_zone = TimeUtil:GetClientTimeGmtOff()
  timeSec = timeSec - local_time_zone + server_time_zone
  return os.date("%Y/%m/%d %H:%M:%S", timeSec)
end

function TimeUtil:TimerToString2(timeSec)
  if not timeSec then
    return
  end
  local server_time_zone = TimeUtil:GetServerTimeGmtOff()
  local local_time_zone = TimeUtil:GetClientTimeGmtOff()
  timeSec = timeSec - local_time_zone + server_time_zone
  return os.date("%Y-%m-%d", timeSec)
end

function TimeUtil:TimerToString3(timeSec)
  if not timeSec then
    return
  end
  local server_time_zone = TimeUtil:GetServerTimeGmtOff()
  local local_time_zone = TimeUtil:GetClientTimeGmtOff()
  timeSec = timeSec - local_time_zone + server_time_zone
  return os.date("%Y-%m-%d %H:%M:%S", timeSec)
end

function TimeUtil:TimerToString4(timeSec)
  if not timeSec then
    return
  end
  local server_time_zone = TimeUtil:GetServerTimeGmtOff()
  local local_time_zone = TimeUtil:GetClientTimeGmtOff()
  timeSec = timeSec - local_time_zone + server_time_zone
  return os.date("%H:%M:%S", timeSec)
end

function TimeUtil:ServerTimeStrToServerTimeSec(serverTimeStr)
  if not serverTimeStr then
    return
  end
  local _, _, y, m, d, hour, min, sec = string.find(serverTimeStr, "(%d+)/(%d+)/(%d+)%s*(%d+):(%d+):(%d+)")
  if not (y and m and d and hour and min) or not sec then
    return
  end
  local timestamp = os.time({
    year = y,
    month = m,
    day = d,
    hour = hour,
    min = min,
    sec = sec
  })
  return timestamp
end

function TimeUtil:TimeStringToTimeSec(timeStr)
  if not timeStr then
    return
  end
  local _, _, y, m, d, hour, min, sec = string.find(timeStr, "(%d+)/(%d+)/(%d+)%s*(%d+):(%d+):(%d+)")
  if not (y and m and d and hour and min) or not sec then
    return
  end
  local timestamp = os.time({
    year = y,
    month = m,
    day = d,
    hour = hour,
    min = min,
    sec = sec
  })
  local server_time_zone = TimeUtil:GetServerTimeGmtOff()
  local local_time_zone = TimeUtil:GetClientTimeGmtOff()
  return timestamp + local_time_zone - server_time_zone
end

function TimeUtil:TimeStringToTimeSec2(timeStr)
  if not timeStr then
    return
  end
  local _, _, y, m, d, hour, min, sec = string.find(timeStr, "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)")
  if not (y and m and d and hour and min) or not sec then
    return
  end
  local timestamp = os.time({
    year = y,
    month = m,
    day = d,
    hour = hour,
    min = min,
    sec = sec
  })
  local server_time_zone = TimeUtil:GetServerTimeGmtOff()
  local local_time_zone = TimeUtil:GetClientTimeGmtOff()
  return timestamp + local_time_zone - server_time_zone
end

function TimeUtil:RegularTimeGMTString(sTimeStr)
  if not sTimeStr then
    return
  end
  local sTimeStr = string.gsub(sTimeStr, "{TimeGMT%s*(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)%s*UTC([+-]%d+)}", function(y, m, d, hour, min, sec, gmt)
    local timestamp = os.time({
      year = y,
      month = m,
      day = d,
      hour = hour,
      min = min,
      sec = sec
    })
    local src_time_zone = gmt * 3600
    local dst_gmt
    if ChannelManager:IsChinaChannel() then
      dst_gmt = 8
    elseif ChannelManager:IsAPChannel() then
      dst_gmt = 9
    else
      dst_gmt = -8
    end
    local dst_time_zone = dst_gmt * 3600
    return os.date("%Y-%m-%d %H:%M:%S UTC", timestamp + dst_time_zone - src_time_zone) .. (0 <= dst_gmt and "+" or "") .. dst_gmt
  end)
  return sTimeStr
end

function TimeUtil:GetOfflineTimeText(iLastLogoutTime, darkColor)
  local serverTime = self:GetServerTimeS() - iLastLogoutTime
  local timeTab = TimeUtil:SecondsToFourUnit(serverTime)
  local dayStr = darkColor and ConfigManager:GetCommonTextById(100060) or ConfigManager:GetCommonTextById(100044)
  local hourStr = darkColor and ConfigManager:GetCommonTextById(100059) or ConfigManager:GetCommonTextById(100043)
  local minStr = darkColor and ConfigManager:GetCommonTextById(100058) or ConfigManager:GetCommonTextById(100042)
  if timeTab.day > 0 then
    return string.gsubnumberreplace(dayStr, timeTab.day)
  elseif 0 < timeTab.hour then
    return string.gsubnumberreplace(hourStr, timeTab.hour)
  elseif timeTab.min == 0 then
    return string.gsubnumberreplace(minStr, 1)
  else
    return string.gsubnumberreplace(minStr, timeTab.min)
  end
end

function TimeUtil:GetTimeInMilliseconds()
  local t = os.date("*t")
  local ms = math.floor(os.clock() % 1 * 1000)
  return string.format("%02s:%02s:%02s.%03s", t.hour, t.min, t.sec, ms)
end

function TimeUtil:SecondToTimeText(second)
  if second <= 0 then
    return ""
  end
  local timeTb = self:SecondsToFourUnit(second)
  if 0 < timeTb.day then
    local day_str = self:GetCommonCountDownDayStr()
    return string.gsubNumberReplace(day_str, timeTb.day)
  elseif timeTb.day == 0 and 0 < timeTb.hour then
    local hour_str = self:GetCommonCountDownHourStr()
    return string.gsubNumberReplace(hour_str, timeTb.hour)
  elseif timeTb.day == 0 and timeTb.hour == 0 and 0 < timeTb.min then
    local day_str = self:GetCommonCountDownMinuteStr()
    return string.gsubNumberReplace(day_str, timeTb.min)
  elseif timeTb.day == 0 and timeTb.hour == 0 and timeTb.min == 0 then
    local day_str = self:GetCommonCountDownSecondStr()
    return string.gsubNumberReplace(day_str, timeTb.sec)
  end
end

function TimeUtil:TimeTableToFormatCNStr2(times)
  local timeTb = self:SecondsToFourUnit(times)
  local sHour
  if timeTb.hour < 10 then
    sHour = "0" .. timeTb.hour
  else
    sHour = timeTb.hour
  end
  local sMin
  if 10 > timeTb.min then
    sMin = "0" .. timeTb.min
  else
    sMin = timeTb.min
  end
  local sSec = string.format("%02d", math.floor(timeTb.sec))
  local hour_str = self:GetCommonCountDownHourStr()
  local min_str = self:GetCommonCountDownMinuteStr()
  local sec_str = self:GetCommonCountDownSecondStr()
  if timeTb.day > 0 then
    local hour = timeTb.day * 24 + sHour
    return string.gsubNumberReplace(hour_str, hour)
  else
    return string.gsubNumberReplace(hour_str, sHour) .. " " .. string.gsubNumberReplace(min_str, sMin) .. " " .. string.gsubNumberReplace(sec_str, sSec)
  end
end

function TimeUtil:SecondsToFormatCNStr3(s)
  local timeTb = self:SecondsToFourUnit(s)
  return self:TimeTableToFormatCNStr3(timeTb)
end

function TimeUtil:TimeTableToFormatCNStr3(timeTb)
  local sHour
  if timeTb.hour < 10 then
    sHour = "0" .. timeTb.hour
  else
    sHour = timeTb.hour
  end
  local sMin
  if 10 > timeTb.min then
    sMin = "0" .. timeTb.min
  else
    sMin = timeTb.min
  end
  local sSec = string.format("%02d", math.floor(timeTb.sec))
  local day_str = self:GetCommonCountDownDayStr()
  local hour_str = self:GetCommonCountDownHourStr()
  local min_str = self:GetCommonCountDownMinuteStr()
  local sec_str = self:GetCommonCountDownSecondStr()
  if timeTb.day > 0 then
    return string.gsubNumberReplace(day_str, timeTb.day) .. string.gsubNumberReplace(hour_str, sHour)
  elseif timeTb.day == 0 and timeTb.hour >= 1 then
    return string.gsubNumberReplace(hour_str, sHour) .. string.gsubNumberReplace(min_str, sMin)
  else
    return string.gsubNumberReplace(min_str, sMin) .. string.gsubNumberReplace(sec_str, sSec)
  end
end

function TimeUtil:SecondsToFormatCNStr4(s)
  local timeTb = self:SecondsToFourUnit(s)
  return self:TimeTableToFormatCNStr4(timeTb)
end

function TimeUtil:TimeTableToFormatCNStr4(timeTb)
  local sHour
  if timeTb.hour < 10 then
    sHour = "0" .. timeTb.hour
  else
    sHour = timeTb.hour
  end
  local sMin
  if 10 > timeTb.min then
    sMin = "0" .. timeTb.min
  else
    sMin = timeTb.min
  end
  local sSec = string.format("%02d", math.floor(timeTb.sec))
  local day_str = self:GetCommonCountDownDayStr()
  local hour_str = self:GetCommonCountDownHourStr2()
  local min_str = self:GetCommonCountDownMinuteStr2()
  local sec_str = self:GetCommonCountDownSecondStr()
  if timeTb.day > 0 then
    return string.gsubNumberReplace(day_str, timeTb.day) .. string.gsubNumberReplace(hour_str, sHour)
  elseif timeTb.day == 0 and timeTb.hour >= 1 then
    return string.gsubNumberReplace(hour_str, sHour) .. string.gsubNumberReplace(min_str, sMin)
  else
    return string.gsubNumberReplace(min_str, sMin) .. string.gsubNumberReplace(sec_str, sSec)
  end
end

function TimeUtil:GetAFewDayDifference(beginTime, endTime)
  local time = endTime - beginTime
  return math.ceil(time / __oneDayOfSecond)
end

function TimeUtil:GetIsDuringStartAndEnd(startTime, endTime)
  if not startTime or not endTime then
    return false
  end
  local zeroTime = self:GetZeroClockTimeS()
  local startTimeSecond = zeroTime + startTime * 3600
  local endTimeSecond = zeroTime + endTime * 3600
  if startTimeSecond < self:GetServerTimeS() and endTimeSecond > self:GetServerTimeS() then
    return true
  end
  return false
end

function TimeUtil:GetITimeNextResetDay(iTime)
  local tempiTime = iTime + self:GetServerTimeGmtOff()
  local commonResetTime = self:GetCommonResetTimeSecond()
  local sameDay4am = math.floor(tempiTime / __oneDayOfSecond) * __oneDayOfSecond + commonResetTime - self:GetServerTimeGmtOff()
  local iTime2 = iTime >= sameDay4am and sameDay4am + __oneDayOfSecond or sameDay4am
  return iTime2
end

function TimeUtil:GetNowServerDate()
  local now = self:GetServerTimeS()
  local nowSvrDate = self:GetServerDate(now)
  return nowSvrDate
end

function TimeUtil:GetOneDayOfSecond()
  return __oneDayOfSecond
end

function TimeUtil:GetCommonCountDownDayStr()
  if self.m_sCommonCountDownDayStr == nil then
    self.m_sCommonCountDownDayStr = CS.ConfFact.LangFormat4DataInit("CommonCountDownDay")
  end
  return self.m_sCommonCountDownDayStr
end

function TimeUtil:GetCommonCountDownHourStr()
  if self.m_sCommonCountDownHourStr == nil then
    self.m_sCommonCountDownHourStr = CS.ConfFact.LangFormat4DataInit("CommonCountDownHour")
  end
  return self.m_sCommonCountDownHourStr
end

function TimeUtil:GetCommonCountDownMinuteStr()
  if self.m_sCommonCountDownMinuteStr == nil then
    self.m_sCommonCountDownMinuteStr = CS.ConfFact.LangFormat4DataInit("CommonCountDownMinute")
  end
  return self.m_sCommonCountDownMinuteStr
end

function TimeUtil:GetCommonCountDownSecondStr()
  if self.m_sCommonCountDownSecondStr == nil then
    self.m_sCommonCountDownSecondStr = CS.ConfFact.LangFormat4DataInit("CommonCountDownSecond")
  end
  return self.m_sCommonCountDownSecondStr
end

function TimeUtil:GetCommonCountDownHourStr2()
  if self.m_sCommonCountDownHourStr2 == nil then
    self.m_sCommonCountDownHourStr2 = CS.ConfFact.LangFormat4DataInit("CommonCountDownHourShort")
  end
  return self.m_sCommonCountDownHourStr2
end

function TimeUtil:GetCommonCountDownMinuteStr2()
  if self.m_sCommonCountDownMinuteStr2 == nil then
    self.m_sCommonCountDownMinuteStr2 = CS.ConfFact.LangFormat4DataInit("CommonCountDownMinuteShort")
  end
  return self.m_sCommonCountDownMinuteStr2
end

return TimeUtil
