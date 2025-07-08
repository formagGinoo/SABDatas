TimeService = {
  m_vAllTimers = {},
  m_vRemoves = {},
  m_IDFactory = 0,
  m_curFrame = 0
}

function TimeService:SetTimer(elapse, times, callbackfunction, param)
  self.m_IDFactory = self.m_IDFactory + 1
  self.m_vAllTimers[self.m_IDFactory] = {
    m_elapse = elapse,
    m_times = times,
    m_callback = callbackfunction,
    m_pastTime = 0,
    m_curTimes = 0,
    m_param = param
  }
  return self.m_IDFactory
end

function TimeService:KillTimer(ID)
  if ID == nil then
    return
  end
  table.insert(self.m_vRemoves, ID)
end

function TimeService:Update()
  if self.m_preTime == nil then
    self.m_preTime = CS.UnityEngine.Time.realtimeSinceStartup
  end
  deltaTimeInSeconds = CS.UnityEngine.Time.realtimeSinceStartup - self.m_preTime
  self.m_curFrame = self.m_curFrame + 1
  self.m_preTime = CS.UnityEngine.Time.realtimeSinceStartup
  if table.getn(self.m_vRemoves) > 0 then
    for key, v in pairs(self.m_vRemoves) do
      self.m_vAllTimers[v] = nil
    end
    self.m_vRemoves = {}
  end
  local keyTables = {}
  for key, _ in pairs(self.m_vAllTimers) do
    keyTables[#keyTables + 1] = key
  end
  table.sort(keyTables, function(a, b)
    return a < b
  end)
  for _, timerKey in ipairs(keyTables) do
    local timer = self.m_vAllTimers[timerKey]
    timer.m_pastTime = timer.m_pastTime + deltaTimeInSeconds
    if timer.m_pastTime >= timer.m_elapse then
      if timer.m_callback then
        local status, result = xpcall(timer.m_callback, function(err)
          local debugInfo = debug.traceback()
          log.error("TimeService Error Stack trace: " .. debugInfo)
          return "TimeService Error Custom error message"
        end, timerKey, timer.m_param)
      end
      timer.m_pastTime = timer.m_pastTime - timer.m_elapse
      timer.m_curTimes = timer.m_curTimes + 1.0
      if 0 <= timer.m_times and timer.m_curTimes >= timer.m_times then
        self.m_vAllTimers[timerKey] = nil
      end
    end
  end
end

function TimeService:ResetTimer(ID)
  if ID == nil then
    return
  end
  Mlog:debug("TimeService:ResetTimer " .. ID)
  self.m_vAllTimers[ID].m_pastTime = 0
  self.m_vAllTimers[ID].m_curTimes = 0
end

function TimeService:resetPreTime()
  self.m_preTime = CS.UnityEngine.Time.realtimeSinceStartup
end

function TimeService:getCurFrame()
  return self.m_curFrame
end

function TimeService:GetTimerLeftTime(ID)
  if not ID then
    return
  end
  local timer = self.m_vAllTimers[ID]
  if not timer then
    return
  end
  local deltaTimeInSeconds = CS.UnityEngine.Time.realtimeSinceStartup - self.m_preTime
  local pastTime = timer.m_pastTime + deltaTimeInSeconds
  if pastTime >= timer.m_elapse then
    return -1
  end
  return timer.m_elapse - pastTime
end

return TimeService
