TimeProfile = class("TimeProfile")
local config

function TimeProfile:ctor()
  self.m_names = {}
  self.m_timeStarts = {}
  self.m_timeFull = {}
  self.m_timeMaxs = {}
  self.m_timeDetail = {}
  self.m_timeCount = {}
  self.m_refCount = {}
  self.m_selfCostTime = 0
  self.m_reset = false
end

function TimeProfile:reset()
  self.m_timeStarts = {}
  self.m_timeFull = {}
  self.m_timeCount = {}
  self.m_timeDetail = {}
  self.m_timeMaxs = {}
  self.m_refCount = {}
  self.m_reset = true
end

function TimeProfile:record(name)
  if not OPEN_TIME_FROFILE then
    return
  end
  if get_time ~= nil then
    table.insert(self.m_names, name)
    table.insert(self.m_timeStarts, get_time())
  end
end

function TimeProfile:getTime(name)
  return self.m_timeFull[name]
end

function TimeProfile:addRefCount(name)
  if self.m_refCount[name] == nil then
    self.m_refCount[name] = 1
  else
    self.m_refCount[name] = self.m_refCount[name] + 1
  end
end

function TimeProfile:init()
end

function TimeProfile:flush()
  if not OPEN_TIME_FROFILE then
    return
  end
  if get_time ~= nil and not self.m_reset then
    local now = get_time()
    local name = self.m_names[#self.m_names]
    local starttime = self.m_timeStarts[#self.m_timeStarts]
    local timecost = now - starttime
    if self.m_timeFull[name] == nil then
      self.m_timeFull[name] = 0
    end
    if self.m_timeMaxs[name] == nil then
      self.m_timeMaxs[name] = 0
    end
    if self.m_timeDetail == nil then
      self.m_timeDetail = {}
    end
    if self.m_timeDetail[name] == nil then
      self.m_timeDetail[name] = {}
    end
    self.m_timeFull[name] = self.m_timeFull[name] + timecost
    self.m_timeMaxs[name] = math.max(timecost, self.m_timeMaxs[name])
    table.remove(self.m_names, #self.m_names)
    table.remove(self.m_timeStarts, #self.m_timeStarts)
    if #self.m_names > 0 then
      if self.m_timeStarts[#self.m_timeStarts] == nil or timecost == nil or self.m_selfCostTime == nil then
        return
      end
      self.m_timeStarts[#self.m_timeStarts] = self.m_timeStarts[#self.m_timeStarts] + timecost + self.m_selfCostTime
    end
    if self.m_timeCount[name] == nil then
      self.m_timeCount[name] = 0
    end
    local crtCount = self.m_timeCount[name]
    self.m_timeDetail[name][crtCount] = timecost
    self.m_timeCount[name] = crtCount + 1
    return timecost
  end
end

function TimeProfile:getCurrentTime(name)
  if self.m_timeCount[name] ~= nil then
    return self.m_timeCount[name]
  end
  return 0
end

function TimeProfile:print()
  if not OPEN_TIME_FROFILE then
    return
  end
  local str = "---------------- time profile begin -------------------\n"
  local ns = {}
  for k, v in pairs(self.m_timeFull) do
    local count = self.m_timeCount[k]
    if 0 < count then
      table.insert(ns, k)
    end
  end
  
  local function _sort(a, b)
    local ta = self.m_timeFull[a] / self.m_timeCount[a]
    local tb = self.m_timeFull[b] / self.m_timeCount[b]
    return ta > tb
  end
  
  table.sort(ns, _sort)
  for _, k in ipairs(ns) do
    local v = self.m_timeFull[k]
    local count = self.m_timeCount[k]
    if 0 < count then
      local maxtime = self.m_timeMaxs[k]
      if config.isClient then
        str = str .. string.format("-- full time : %.3f ms , avg time : %.3f us , max time : %.3f us , name : %s , count : %d\n", v / 10000, v / count / 10, maxtime / 10, k, count)
      else
        str = str .. string.format("-- full time : %.3f ms , avg time : %.3f us , max time : %.3f us , name : %s , count : %d\n", v / 1000, v / count, maxtime, k, count)
      end
    end
  end
  local bShowDetail = false
  if bShowDetail then
    for k, v in pairs(self.m_timeFull) do
      local count = self.m_timeCount[k]
      if 0 < count then
        local costList = self.m_timeDetail[k]
        local str = {}
        for k1, v1 in pairs(costList) do
          str[#str + 1] = v1
          str[#str + 1] = ","
        end
        str = table.concat(str, "")
        log.debug([[
--- %s detail :
%s]], k, str)
      end
    end
  end
  str = str .. "----------------  time profile end  -------------------"
  log.debug(str)
  self:reset()
end

function TimeProfile:print_ref()
  if not BaseRequires.g_bDebug then
    return
  end
  log.debug("---------------- ref count begin -------------------")
  local list = {}
  for k, v in pairs(self.m_refCount) do
    local tmp = {name = k, count = v}
    table.insert(list, tmp)
  end
  
  local function _comp(a, b)
    return a.count > b.count
  end
  
  table.sort(list, _comp)
  for i, k in ipairs(list) do
    if k.count > 100 then
      log.debug("...ref : %70s - %d", k.name, k.count)
    end
  end
  log.debug("----------------  ref count end  -------------------")
end

local TIME_PROFILE = TimeProfile.new()
return TIME_PROFILE
