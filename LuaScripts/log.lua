log = {}
local ILog = CS.ILog
local string = _ENV.string
local tostring = _ENV.tostring

function log.info(...)
  local info = debug.getinfo(2, "Sl")
  local _param = {
    ...
  }
  if 1 < #_param then
    str = table.concat(_param, "")
  else
    str = _param[1]
  end
  local info = table.concat({
    str,
    [[

source:]],
    info.source,
    ", line:",
    info.currentline
  })
  ILog.Info(tostring(info))
end

function log.debug(...)
  local info = debug.getinfo(2, "Sl")
  local _param = {
    ...
  }
  if 1 < #_param then
    str = table.concat(_param, "")
  else
    str = _param[1]
  end
  local debug = table.concat({
    str,
    [[

source:]],
    info.source,
    ", line:",
    info.currentline
  })
  ILog.Debug(tostring(debug))
end

function log.warn(...)
  local info = debug.getinfo(2, "Sl")
  local _param = {
    ...
  }
  if 1 < #_param then
    str = table.concat(_param, "")
  else
    str = _param[1]
  end
  local warn = table.concat({
    str,
    [[

source:]],
    info.source,
    ", line:",
    info.currentline
  })
  ILog.Warn(tostring(warn))
end

function log.error(...)
  local info = debug.getinfo(2, "Sl")
  local _param = {
    ...
  }
  if 1 < #_param then
    str = table.concat(_param, "")
  else
    str = _param[1]
  end
  local errorr = table.concat({
    str,
    [[

source:]],
    info.source,
    ", line:",
    info.currentline
  })
  ILog.Error(tostring(errorr))
end

function log.report(...)
  local info = debug.getinfo(2, "Sl")
  local _param = {
    ...
  }
  if 1 < #_param then
    str = table.concat(_param, "")
  else
    str = _param[1]
  end
  local report = table.concat({
    str,
    [[

source:]],
    info.source,
    ", line:",
    info.currentline
  })
  ILog.Report(tostring(report))
end

return log
