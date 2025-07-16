local Debug = {}
local RegSampleFunc = CS.LuaCallCS.RegSampleFunc
local PushSample = CS.LuaCallCS.PushSample
local PopSample = CS.LuaCallCS.PopSample

function Debug.ProfileClassCost(clazz, whitelist)
  if not GameSettings.m_bEanbleApiCostProfile then
    return
  end
  
  local function ishook(apiname)
    if whitelist == nil then
      return false
    end
    for _, pattern in ipairs(whitelist) do
      if string.match(apiname, pattern) then
        return true
      end
    end
    return false
  end
  
  local function wrapper(tag, oldfunc)
    local itag = RegSampleFunc(tag)
    
    local function newfunc(...)
      PushSample(itag)
      local retv = {
        oldfunc(...)
      }
      PopSample()
      if table.empty(retv) then
        return nil
      end
      return unpack(retv)
    end
    
    return newfunc
  end
  
  local classname = clazz.__cname
  for k, v in pairs(clazz) do
    if type(v) == "function" and ishook(k) then
      clazz[k] = wrapper(classname .. ":" .. k, v)
    end
  end
end

function Debug.ProfileFunction(func, name)
  if not GameSettings.m_bEanbleApiCostProfile then
    return func
  end
  
  local function wrapper(tag, oldfunc)
    local function newfunc(...)
      local itag = RegSampleFunc(tag)
      
      PushSample(itag)
      local retv = {
        oldfunc(...)
      }
      PopSample()
      if table.empty(retv) then
        return nil
      end
      return unpack(retv)
    end
    
    return newfunc
  end
  
  return wrapper(name, func)
end

local profilerTags = {}

function Debug.ProfileBegin(tag)
  local iTag = profilerTags[tag]
  if iTag == nil then
    iTag = RegSampleFunc(tag)
    profilerTags[tag] = iTag
  end
  PushSample(iTag)
end

function Debug.ProfileEnd()
  PopSample()
end

return Debug
