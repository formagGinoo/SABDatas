local callback = {}

function callback.handler(obj, method)
  return function(...)
    if method ~= nil then
      return method(obj, ...)
    end
  end
end

function callback.handlerEx(obj, methodName, ...)
  local arg_index = select("#", ...)
  local args = {
    ...
  }
  return function(...)
    local method = obj[methodName]
    if method ~= nil then
      local _targs = {
        ...
      }
      local tmpIndex = arg_index
      for i = 1, #_targs do
        tmpIndex = tmpIndex + 1
        args[tmpIndex] = _targs[i]
      end
      return method(obj, table.unpack(args, 1, tmpIndex))
    end
  end
end

function callback.handlerSFXEx(obj, methodName, sfxId, ...)
  local arg_index = select("#", ...)
  local args = {
    ...
  }
  return function(...)
    local method = obj[methodName]
    if method ~= nil then
      local _targs = {
        ...
      }
      local tmpIndex = arg_index
      for i = 1, #_targs do
        tmpIndex = tmpIndex + 1
        args[tmpIndex] = _targs[i]
      end
      if sfxId then
        CS.UI.UISoundCenter.PlayByID(sfxId, "Play_ui_click")
      else
        CS.UI.UISoundCenter.Play("Play_ui_click")
      end
      return method(obj, table.unpack(args, 1, tmpIndex))
    end
  end
end

function callback.handlerParams(obj, method, ...)
  return function(...)
    if method ~= nil then
      return method(obj, ...)
    end
  end
end

function callback.handler1(obj, method, param1)
  return function(...)
    if method ~= nil then
      return method(obj, param1, ...)
    end
  end
end

function callback.handler2(obj, method, param1, param2)
  return function(...)
    if method ~= nil then
      return method(obj, param1, param2, ...)
    end
  end
end

function callback.registerViewCallback(logicObj, viewObj, strRegister)
  if logicObj ~= nil then
    for k, v in pairs(logicObj.class) do
      local startpos = string.find(k, strRegister)
      if startpos == 1 and viewObj.class[k] ~= nil then
        logicObj[k] = function(logicObj, ...)
          return viewObj.class[k](viewObj, ...)
        end
      end
    end
    local allparentfun = logicObj.class.super
    if allparentfun ~= nil then
      for k, v in pairs(allparentfun) do
        local startpos = string.find(k, strRegister)
        if startpos == 1 and viewObj.class[k] ~= nil then
          logicObj[k] = function(logicObj, ...)
            return viewObj.class[k](viewObj, ...)
          end
        end
      end
    end
  end
end

return callback
