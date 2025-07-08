local common = {}

function common.iff(c, a, b)
  if c then
    return a
  else
    return b
  end
end

function common.instantiate(go)
  local aObj = CS.UnityEngine.GameObject.Instantiate(go)
  return aObj
end

function common.instantiateToParent(go, parentGo)
  local aObj = CS.UnityEngine.GameObject.Instantiate(go, parentGo)
  return aObj
end

function common.instantiateToParentInWorldSpace(go, parentGo, bInWorldSpace)
  local aObj = CS.UnityEngine.GameObject.Instantiate(go, parentGo, bInWorldSpace)
  return aObj
end

local function checkFunction(func)
  if func then
    local type_f = type(func)
    return type_f == "function"
  end
end

function common.tryCatch(try, catch, finally, printError)
  if not try then
    log.error("try function is nil")
    return
  end
  if not checkFunction(try) then
    log.error("try is not a function")
    return
  end
  local ok, errors = xpcall(try, debug.traceback)
  if not ok then
    if printError then
      log.error(tostring(errors))
    end
    if catch and checkFunction(catch) then
      pcall(catch, errors)
    end
  end
  if finally and checkFunction(finally) then
    pcall(finally, ok, errors)
  end
  if ok then
    return errors
  end
end

return common
