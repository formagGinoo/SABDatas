local openAttachMode = true
local attachInterval = 1
local customGetSocketInstance
local consoleLogLevel = 2
local connectTimeoutSec = 0.005
local debuggerVer = "3.1.0"
LuaPanda = {}
local this = LuaPanda
local tools = {}
this.tools = tools
this.curStackId = 0
local json
local hookState = {
  DISCONNECT_HOOK = 0,
  LITE_HOOK = 1,
  MID_HOOK = 2,
  ALL_HOOK = 3
}
local runState = {
  DISCONNECT = 0,
  WAIT_CMD = 1,
  STOP_ON_ENTRY = 2,
  RUN = 3,
  STEPOVER = 4,
  STEPIN = 5,
  STEPOUT = 6,
  STEPOVER_STOP = 7,
  STEPIN_STOP = 8,
  STEPOUT_STOP = 9,
  HIT_BREAKPOINT = 10
}
local TCPSplitChar = "|*|"
local MAX_TIMEOUT_SEC = 86400
local currentRunState, currentHookState
local breaks = {}
this.breaks = breaks
local recCallbackId = ""
local luaFileExtension = ""
local cwd = ""
local DebuggerFileName = ""
local DebuggerToolsName = ""
local lastRunFunction = {}
local currentCallStack = {}
local hitBP = false
local TempFilePath_luaString = ""
local connectHost, connectPort, sock, OSType, clibPath, hookLib, adapterVer
local logLevel = 1
local variableRefIdx = 1
local variableRefTab = {}
local lastRunFilePath = ""
local pathCaseSensitivity = true
local recvMsgQueue = {}
local coroutinePool = {}
local winDiskSymbolUpper = false
local isNeedB64EncodeStr = false
local loadclibErrReason = "launch.json文件的配置项useCHook被设置为false."
local OSTypeErrTip = ""
local pathErrTip = ""
local winDiskSymbolTip = ""
local isAbsolutePath = false
local stopOnEntry, userSetUseClib
local autoPathMode = false
local stepOverCounter = 0
local stepOutCounter = 0
local HOOK_LEVEL = 3
local isUseLoadstring = 0
local debugger_loadString, coroutineCreate
local stopConnectTime = 0
local isInMainThread
local receiveMsgTimer = 0
local formatPathCache = {}
local isUserSetClibPath = false
if _VERSION == "Lua 5.1" then
  debugger_loadString = loadstring
else
  debugger_loadString = load
end
local env = setmetatable({}, {
  __index = function(_, varName)
    local ret = this.getWatchedVariable(varName, _G.LuaPanda.curStackId, false)
    return ret
  end,
  __newindex = function(_, varName, newValue)
    this.setVariableValue(varName, _G.LuaPanda.curStackId, newValue)
  end
})

function this.start(host, port)
  host = tostring(host or "127.0.0.1")
  port = tonumber(port) or 8818
  this.printToConsole("Debugger start. connect host:" .. host .. " port:" .. tostring(port), 1)
  if sock ~= nil then
    this.printToConsole("[Warning] 调试器已经启动，请不要再次调用start()", 1)
    return
  end
  this.changeRunState(runState.DISCONNECT)
  if not this.reGetSock() then
    this.printToConsole("[Error] Start debugger but get Socket fail , please install luasocket!", 2)
    return
  end
  connectHost = host
  connectPort = port
  local sockSuccess = sock and sock:connect(connectHost, connectPort)
  if sockSuccess ~= nil then
    this.printToConsole("first connect success!")
    this.connectSuccess()
  else
    this.printToConsole("first connect failed!")
    this.changeHookState(hookState.DISCONNECT_HOOK)
  end
end

function this.connectSuccess()
  this.changeRunState(runState.WAIT_CMD)
  this.printToConsole("connectSuccess", 1)
  local ret = this.debugger_wait_msg()
  if DebuggerFileName == "" then
    local info = debug.getinfo(1, "S")
    for k, v in pairs(info) do
      if k == "source" then
        DebuggerFileName = v
        this.printToVSCode("DebuggerFileName:" .. tostring(DebuggerFileName))
        if hookLib ~= nil then
          hookLib.sync_debugger_path(DebuggerFileName)
        end
      end
    end
  end
  if DebuggerToolsName == "" then
    DebuggerToolsName = tools.getFileSource()
    if hookLib ~= nil then
      hookLib.sync_tools_path(DebuggerToolsName)
    end
  end
  if ret == false then
    this.printToVSCode("[debugger error]初始化未完成, 建立连接但接收初始化消息失败。请更换端口重试", 2)
    return
  end
  this.printToVSCode("debugger init success", 1)
  this.changeHookState(hookState.ALL_HOOK)
  if hookLib == nil then
    if coroutineCreate == nil and type(coroutine.create) == "function" then
      this.printToConsole("change coroutine.create")
      coroutineCreate = coroutine.create
      
      function coroutine.create(...)
        local co = coroutineCreate(...)
        table.insert(coroutinePool, co)
        this.changeCoroutineHookState()
        return co
      end
    else
      this.printToConsole("restart coroutine")
      this.changeCoroutineHookState()
    end
  end
end

function this.clearData()
  OSType = nil
  clibPath = nil
  breaks = {}
  formatPathCache = {}
  this.breaks = breaks
  if hookLib ~= nil then
    hookLib.sync_breakpoints()
    hookLib.clear_pathcache()
  end
end

function this.disconnect()
  this.printToConsole("Debugger disconnect", 1)
  this.clearData()
  this.changeHookState(hookState.DISCONNECT_HOOK)
  stopConnectTime = os.time()
  this.changeRunState(runState.DISCONNECT)
  if sock ~= nil then
    sock:close()
  end
  if connectPort == nil or connectHost == nil then
    this.printToConsole("[Warning] User call LuaPanda.disconnect() before set debug ip & port, please call LuaPanda.start() first!", 2)
    return
  end
  this.reGetSock()
end

function this.getBreaks()
  return breaks
end

function this.getCWD()
  local ly = this.getSpecificFunctionStackLevel(lastRunFunction.func)
  if type(ly) ~= "number" then
    ly = 2
  end
  local runSource = lastRunFunction.source
  if runSource == nil and hookLib ~= nil then
    runSource = this.getPath(tostring(hookLib.get_last_source()))
  end
  local info = debug.getinfo(ly, "S")
  return "cwd:      " .. cwd .. [[

getinfo:  ]] .. info.source .. [[

format:   ]] .. tostring(runSource)
end

function this.getBaseInfo()
  local strTable = {}
  local jitVer = ""
  if jit and jit.version then
    jitVer = "," .. tostring(jit.version)
  end
  strTable[#strTable + 1] = "Lua Ver:" .. _VERSION .. jitVer .. " | adapterVer:" .. tostring(adapterVer) .. " | Debugger Ver:" .. tostring(debuggerVer)
  local moreInfoStr = ""
  if hookLib ~= nil then
    local clibVer, forluaVer = hookLib.sync_getLibVersion()
    local clibStr = forluaVer ~= nil and tostring(clibVer) .. " for " .. tostring(math.ceil(forluaVer)) or tostring(clibVer)
    strTable[#strTable + 1] = " | hookLib Ver:" .. clibStr
    moreInfoStr = moreInfoStr .. "说明: 已加载 libpdebug 库."
  else
    moreInfoStr = moreInfoStr .. "说明: 未能加载 libpdebug 库。原因请使用 LuaPanda.doctor() 查看"
  end
  local outputIsUseLoadstring = false
  if type(isUseLoadstring) == "number" and isUseLoadstring == 1 then
    outputIsUseLoadstring = true
  end
  strTable[#strTable + 1] = " | supportREPL:" .. tostring(outputIsUseLoadstring)
  strTable[#strTable + 1] = " | useBase64EncodeString:" .. tostring(isNeedB64EncodeStr)
  strTable[#strTable + 1] = " | codeEnv:" .. tostring(OSType) .. "\n"
  strTable[#strTable + 1] = moreInfoStr
  if OSTypeErrTip ~= nil and OSTypeErrTip ~= "" then
    strTable[#strTable + 1] = "\n" .. OSTypeErrTip
  end
  return table.concat(strTable)
end

function this.doctor()
  local strTable = {}
  if debuggerVer ~= adapterVer then
    strTable[#strTable + 1] = "\n- 建议更新版本\nLuaPanda VSCode插件版本是" .. adapterVer .. ", LuaPanda.lua文件版本是" .. debuggerVer .. "。建议检查并更新到最新版本。"
    strTable[#strTable + 1] = "\n更新方式   : https://github.com/Tencent/LuaPanda/blob/master/Docs/Manual/update.md"
    strTable[#strTable + 1] = "\nRelease版本: https://github.com/Tencent/LuaPanda/releases"
  end
  if hookLib == nil then
    strTable[#strTable + 1] = "\n\n- libpdebug 库没有加载\n"
    if userSetUseClib then
      if isUserSetClibPath == true then
        strTable[#strTable + 1] = "用户使用 LuaPanda.lua 中 clibPath 变量指定了 plibdebug 的位置: " .. clibPath
        if this.tryRequireClib("libpdebug", clibPath) then
          strTable[#strTable + 1] = "\n引用成功"
        else
          strTable[#strTable + 1] = "\n引用错误:" .. loadclibErrReason
        end
      else
        local clibExt, platform
        if OSType == "Darwin" then
          clibExt = "/?.so;"
          platform = "mac"
        elseif OSType == "Linux" then
          clibExt = "/?.so;"
          platform = "linux"
        else
          clibExt = "/?.dll;"
          platform = "win"
        end
        local lua_ver
        if _VERSION == "Lua 5.1" then
          lua_ver = "501"
        else
          lua_ver = "503"
        end
        local x86Path = clibPath .. platform .. "/x86/" .. lua_ver .. clibExt
        local x64Path = clibPath .. platform .. "/x86_64/" .. lua_ver .. clibExt
        strTable[#strTable + 1] = "尝试引用x64库: " .. x64Path
        if this.tryRequireClib("libpdebug", x64Path) then
          strTable[#strTable + 1] = "\n引用成功"
        else
          strTable[#strTable + 1] = "\n引用错误:" .. loadclibErrReason
          strTable[#strTable + 1] = "\n尝试引用x86库: " .. x86Path
          if this.tryRequireClib("libpdebug", x86Path) then
            strTable[#strTable + 1] = "\n引用成功"
          else
            strTable[#strTable + 1] = "\n引用错误:" .. loadclibErrReason
          end
        end
      end
    else
      strTable[#strTable + 1] = "原因是" .. loadclibErrReason
    end
  end
  local runSource = lastRunFilePath
  if hookLib ~= nil then
    runSource = this.getPath(tostring(hookLib.get_last_source()))
  end
  if not autoPathMode and runSource and runSource ~= "" then
    local isFileExist = this.fileExists(runSource)
    if not isFileExist then
      strTable[#strTable + 1] = "\n\n- 路径存在问题\n"
      local pathArray = this.stringSplit(runSource, "/")
      local fileMatch = false
      for key, _ in pairs(this.getBreaks()) do
        if string.find(key, pathArray[#pathArray], 1, true) then
          fileMatch = true
          strTable[#strTable + 1] = this.getCWD()
          strTable[#strTable + 1] = [[

filepath: ]] .. key
          if isAbsolutePath then
            strTable[#strTable + 1] = "\n说明:从lua虚拟机获取到的是绝对路径，format使用getinfo路径。"
          else
            strTable[#strTable + 1] = "\n说明:从lua虚拟机获取到的是相对路径，调试器运行依赖的绝对路径(format)是来源于cwd+getinfo拼接。"
          end
          strTable[#strTable + 1] = "\nfilepath是VSCode通过获取到的文件正确路径 , 对比format和filepath，调整launch.json中CWD，或改变VSCode打开文件夹的位置。使format和filepath一致即可。\n如果format和filepath路径仅大小写不一致，设置launch.json中 pathCaseSensitivity:false 可忽略路径大小写"
        end
      end
      if fileMatch == false then
        strTable[#strTable + 1] = "\n找不到文件:" .. runSource .. ", 请检查路径是否正确。\n或者在VSCode文件" .. pathArray[#pathArray] .. "中打一个断点后，再执行一次doctor命令，查看路径分析结果。"
      end
    end
  end
  if logLevel < 1 or consoleLogLevel < 1 then
    strTable[#strTable + 1] = "\n\n- 日志等级\n"
    if logLevel < 1 then
      strTable[#strTable + 1] = "当前日志等级是" .. logLevel .. ", 会产生大量日志，降低调试速度。建议调整launch.json中logLevel:1"
    end
    if consoleLogLevel < 1 then
      strTable[#strTable + 1] = "当前console日志等级是" .. consoleLogLevel .. ", 过低的日志等级会降低调试速度，建议调整LuaPanda.lua文件头部consoleLogLevel=2"
    end
  end
  if #strTable == 0 then
    strTable[#strTable + 1] = "未检测出问题"
  end
  return table.concat(strTable)
end

function this.fileExists(path)
  local f = io.open(path, "r")
  if f ~= nil then
    io.close(f)
    return true
  else
    return false
  end
end

function this.getInfo()
  local strTable = {}
  strTable[#strTable + 1] = [[

- Base Info: 
]]
  strTable[#strTable + 1] = this.getBaseInfo()
  strTable[#strTable + 1] = [[


- User Setting: 
]]
  strTable[#strTable + 1] = "stopOnEntry:" .. tostring(stopOnEntry) .. " | "
  strTable[#strTable + 1] = "logLevel:" .. logLevel .. " | "
  strTable[#strTable + 1] = "consoleLogLevel:" .. consoleLogLevel .. " | "
  strTable[#strTable + 1] = "pathCaseSensitivity:" .. tostring(pathCaseSensitivity) .. " | "
  strTable[#strTable + 1] = "attachMode:" .. tostring(openAttachMode) .. " | "
  strTable[#strTable + 1] = "autoPathMode:" .. tostring(autoPathMode) .. " | "
  if userSetUseClib then
    strTable[#strTable + 1] = "useCHook:true"
  else
    strTable[#strTable + 1] = "useCHook:false"
  end
  if logLevel == 0 or consoleLogLevel == 0 then
    strTable[#strTable + 1] = "\n说明:日志等级过低，会影响执行效率。请调整logLevel和consoleLogLevel值 >= 1"
  end
  strTable[#strTable + 1] = [[


- Path Info: 
]]
  strTable[#strTable + 1] = "clibPath: " .. tostring(clibPath) .. "\n"
  strTable[#strTable + 1] = "debugger: " .. this.getPath(DebuggerFileName) .. "\n"
  strTable[#strTable + 1] = this.getCWD()
  if not autoPathMode then
    if isAbsolutePath then
      strTable[#strTable + 1] = "\n说明:从lua虚拟机获取到的是绝对路径，format使用getinfo路径。" .. winDiskSymbolTip
    else
      strTable[#strTable + 1] = "\n说明:从lua虚拟机获取到的路径(getinfo)是相对路径，调试器运行依赖的绝对路径(format)是来源于cwd+getinfo拼接。如format路径错误请尝试调整cwd或改变VSCode打开文件夹的位置。也可以在format对应的文件下打一个断点，调整直到format和Breaks Info中断点路径完全一致。" .. winDiskSymbolTip
    end
  else
    strTable[#strTable + 1] = "\n说明:已开启autoPathMode自动路径模式，调试器会根据getinfo获得的文件名自动查找文件位置，请确保VSCode打开的工程中不存在同名lua文件。"
  end
  if pathErrTip ~= nil and pathErrTip ~= "" then
    strTable[#strTable + 1] = "\n" .. pathErrTip
  end
  strTable[#strTable + 1] = [[


- Breaks Info: 
]]
  strTable[#strTable + 1] = this.serializeTable(this.getBreaks(), "breaks")
  return table.concat(strTable)
end

function this.isInMain()
  return isInMainThread
end

function this.tryRequireClib(libName, libPath)
  this.printToVSCode("tryRequireClib search : [" .. libName .. "] in " .. libPath)
  local savedCpath = package.cpath
  package.cpath = package.cpath .. ";" .. libPath
  this.printToVSCode("package.cpath:" .. package.cpath)
  local status, err = pcall(function()
    hookLib = require(libName)
  end)
  if status then
    if type(hookLib) == "table" and this.getTableMemberNum(hookLib) > 0 then
      this.printToVSCode("tryRequireClib success : [" .. libName .. "] in " .. libPath)
      package.cpath = savedCpath
      return true
    else
      loadclibErrReason = "tryRequireClib fail : require success, but member function num <= 0; [" .. libName .. "] in " .. libPath
      this.printToVSCode(loadclibErrReason)
      hookLib = nil
      package.cpath = savedCpath
      return false
    end
  else
    loadclibErrReason = err
    this.printToVSCode("[Require clib error]: " .. err, 0)
  end
  package.cpath = savedCpath
  return false
end

function this.revFindString(str, subPattern, plain)
  local revStr = string.reverse(str)
  local _, idx = string.find(revStr, subPattern, 1, plain)
  if idx == nil then
    return nil
  end
  return string.len(revStr) - idx + 1
end

function this.revSubString(str, subStr, plain)
  local idx = this.revFindString(str, subStr, plain)
  if idx == nil then
    return nil
  end
  return string.sub(str, idx + 1, str.length)
end

function this.stringSplit(str, separator)
  local retStrTable = {}
  string.gsub(str, "[^" .. separator .. "]+", function(word)
    table.insert(retStrTable, word)
  end)
  return retStrTable
end

function this.setCallbackId(id)
  if id ~= nil and id ~= "0" then
    recCallbackId = tostring(id)
  end
end

function this.getCallbackId()
  if recCallbackId == nil then
    recCallbackId = "0"
  end
  local id = recCallbackId
  recCallbackId = "0"
  return id
end

function this.trim(s)
  return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function this.getTableMemberNum(t)
  local retNum = 0
  if type(t) ~= "table" then
    this.printToVSCode("[debugger Error] getTableMemberNum get " .. tostring(type(t)), 2)
    return retNum
  end
  for k, v in pairs(t) do
    retNum = retNum + 1
  end
  return retNum
end

function this.getMsgTable(cmd, callbackId)
  callbackId = callbackId or 0
  local msgTable = {}
  msgTable.cmd = cmd
  msgTable.callbackId = callbackId
  msgTable.info = {}
  return msgTable
end

function this.serializeTable(tab, name)
  local sTable = tools.serializeTable(tab, name)
  return sTable
end

function this.printToVSCode(str, printLevel, type)
  type = type or 0
  printLevel = printLevel or 0
  if currentRunState == runState.DISCONNECT or printLevel < logLevel then
    return
  end
  local sendTab = {}
  sendTab.callbackId = "0"
  if type == 0 then
    sendTab.cmd = "log"
  else
    sendTab.cmd = "tip"
  end
  sendTab.info = {}
  sendTab.info.logInfo = tostring(str)
  this.sendMsg(sendTab)
end

function this.printToConsole(str, printLevel)
  printLevel = printLevel or 0
  if printLevel < consoleLogLevel then
    return
  end
  print("[LuaPanda] " .. tostring(str))
end

function this.genUnifiedPath(path)
  if path == "" or path == nil then
    return ""
  end
  if pathCaseSensitivity == false then
    path = string.lower(path)
  end
  path = string.gsub(path, "\\", "/")
  local pathTab = this.stringSplit(path, "/")
  local newPathTab = {}
  for k, v in ipairs(pathTab) do
    if v == "." then
    elseif v == ".." and 1 <= #newPathTab and newPathTab[#newPathTab]:sub(2, 2) ~= ":" then
      table.remove(newPathTab)
    else
      table.insert(newPathTab, v)
    end
  end
  local newpath = table.concat(newPathTab, "/")
  if path:sub(1, 1) == "/" then
    newpath = "/" .. newpath
  end
  if "Windows_NT" == OSType then
    if winDiskSymbolUpper then
      newpath = newpath:gsub("^%a:", string.upper)
      winDiskSymbolTip = "路径中Windows盘符已转为大写。"
    else
      newpath = newpath:gsub("^%a:", string.lower)
      winDiskSymbolTip = "路径中Windows盘符已转为小写。"
    end
  end
  return newpath
end

function this.getCacheFormatPath(source)
  if source == nil then
    return formatPathCache
  end
  return formatPathCache[source]
end

function this.setCacheFormatPath(source, dest)
  formatPathCache[source] = dest
end

function this.sendLuaMemory()
  local luaMem = collectgarbage("count")
  local sendTab = {}
  sendTab.callbackId = "0"
  sendTab.cmd = "refreshLuaMemory"
  sendTab.info = {}
  sendTab.info.memInfo = tostring(luaMem)
  this.sendMsg(sendTab)
end

function this.reGetSock()
  if sock ~= nil then
    pcall(function()
      sock:close()
    end)
  end
  sock = lua_extension and lua_extension.luasocket and lua_extension.luasocket().tcp()
  if sock == nil then
    if pcall(function()
      sock = require("socket.core").tcp()
    end) then
      this.printToConsole("reGetSock success")
      sock:settimeout(connectTimeoutSec)
    elseif customGetSocketInstance and pcall(function()
      sock = customGetSocketInstance()
    end) then
      this.printToConsole("reGetSock custom success")
      sock:settimeout(connectTimeoutSec)
    else
      this.printToConsole("[Error] reGetSock fail", 2)
      return false
    end
  else
    this.printToConsole("reGetSock ue4 success")
    sock:settimeout(connectTimeoutSec)
  end
  return true
end

function this.reConnect()
  if currentHookState == hookState.DISCONNECT_HOOK then
    if os.time() - stopConnectTime < attachInterval then
      this.printToConsole("Reconnect time less than 1s")
      this.printToConsole("os.time:" .. os.time() .. " | stopConnectTime:" .. stopConnectTime)
      return 1
    end
    if sock == nil then
      this.reGetSock()
    end
    local sockSuccess, status = sock:connect(connectHost, connectPort)
    if sockSuccess == 1 or status == "already connected" then
      this.printToConsole("reconnect success")
      this.connectSuccess()
    else
      this.printToConsole("reconnect failed . retCode:" .. tostring(sockSuccess) .. "  status:" .. status)
      stopConnectTime = os.time()
    end
    return 1
  end
  return 0
end

function this.sendMsg(sendTab)
  if isNeedB64EncodeStr and sendTab.info ~= nil then
    for _, v in ipairs(sendTab.info) do
      if v.type == "string" then
        v.value = tools.base64encode(v.value)
      end
    end
  end
  local sendStr = json.encode(sendTab)
  if currentRunState == runState.DISCONNECT then
    this.printToConsole("[debugger error] disconnect but want sendMsg:" .. sendStr, 2)
    this.disconnect()
    return
  end
  local succ, err
  if pcall(function()
    succ, err = sock:send(sendStr .. TCPSplitChar .. "\n")
  end) and succ == nil and err == "closed" then
    this.disconnect()
  end
end

function this.dataProcess(dataStr)
  this.printToVSCode("debugger get:" .. dataStr)
  local dataTable = json.decode(dataStr)
  if dataTable == nil then
    this.printToVSCode("[error] Json is error", 2)
    return
  end
  if dataTable.callbackId ~= "0" then
    this.setCallbackId(dataTable.callbackId)
  end
  if dataTable.cmd == "continue" then
    this.changeRunState(runState.RUN)
    local msgTab = this.getMsgTable("continue", this.getCallbackId())
    this.sendMsg(msgTab)
  elseif dataTable.cmd == "stopOnStep" then
    this.changeRunState(runState.STEPOVER)
    local msgTab = this.getMsgTable("stopOnStep", this.getCallbackId())
    this.sendMsg(msgTab)
    this.changeHookState(hookState.ALL_HOOK)
  elseif dataTable.cmd == "stopOnStepIn" then
    this.changeRunState(runState.STEPIN)
    local msgTab = this.getMsgTable("stopOnStepIn", this.getCallbackId())
    this.sendMsg(msgTab)
    this.changeHookState(hookState.ALL_HOOK)
  elseif dataTable.cmd == "stopOnStepOut" then
    this.changeRunState(runState.STEPOUT)
    local msgTab = this.getMsgTable("stopOnStepOut", this.getCallbackId())
    this.sendMsg(msgTab)
    this.changeHookState(hookState.ALL_HOOK)
  elseif dataTable.cmd == "setBreakPoint" then
    this.printToVSCode("dataTable.cmd == setBreakPoint")
    local bkPath = dataTable.info.path
    bkPath = this.genUnifiedPath(bkPath)
    if autoPathMode then
      bkPath = this.getFilenameFromPath(bkPath)
    end
    this.printToVSCode("setBreakPoint path:" .. tostring(bkPath))
    breaks[bkPath] = dataTable.info.bks
    for k, v in pairs(breaks) do
      if next(v) == nil then
        breaks[k] = nil
      end
    end
    if hookLib ~= nil then
      hookLib.sync_breakpoints()
    end
    if currentRunState ~= runState.WAIT_CMD then
      if hookLib == nil then
        local fileBP, G_BP = this.checkHasBreakpoint(lastRunFilePath)
        if fileBP == false then
          if G_BP == true then
            this.changeHookState(hookState.MID_HOOK)
          else
            this.changeHookState(hookState.LITE_HOOK)
          end
        else
          this.changeHookState(hookState.ALL_HOOK)
        end
      end
    else
      local msgTab = this.getMsgTable("setBreakPoint", this.getCallbackId())
      this.sendMsg(msgTab)
      return
    end
    local msgTab = this.getMsgTable("setBreakPoint", this.getCallbackId())
    this.sendMsg(msgTab)
    this.printToVSCode("LuaPanda.getInfo()\n" .. this.getInfo())
    this.debugger_wait_msg()
  elseif dataTable.cmd == "setVariable" then
    if currentRunState == runState.STOP_ON_ENTRY or currentRunState == runState.HIT_BREAKPOINT or currentRunState == runState.STEPOVER_STOP or currentRunState == runState.STEPIN_STOP or currentRunState == runState.STEPOUT_STOP then
      local msgTab = this.getMsgTable("setVariable", this.getCallbackId())
      local varRefNum = tonumber(dataTable.info.varRef)
      local newValue = tostring(dataTable.info.newValue)
      local needFindVariable = true
      local varName = tostring(dataTable.info.varName)
      local first_chr = string.sub(newValue, 1, 1)
      local end_chr = string.sub(newValue, -1, -1)
      if first_chr == end_chr and (first_chr == "'" or first_chr == "\"") then
        newValue = string.sub(newValue, 2, -2)
        needFindVariable = false
      end
      if newValue == "nil" and needFindVariable == true then
        newValue = nil
        needFindVariable = false
      elseif newValue == "true" and needFindVariable == true then
        newValue = true
        needFindVariable = false
      elseif newValue == "false" and needFindVariable == true then
        newValue = false
        needFindVariable = false
      elseif tonumber(newValue) and needFindVariable == true then
        newValue = tonumber(newValue)
        needFindVariable = false
      end
      if dataTable.info.stackId ~= nil and tonumber(dataTable.info.stackId) ~= nil and 1 < tonumber(dataTable.info.stackId) then
        this.curStackId = tonumber(dataTable.info.stackId)
      else
        this.printToVSCode("未能获取到堆栈层级，默认使用 this.curStackId;")
      end
      if varRefNum < 10000 then
        msgTab.info = this.createSetValueRetTable(varName, newValue, needFindVariable, this.curStackId, variableRefTab[varRefNum])
      else
        local setLimit
        if 10000 <= varRefNum and varRefNum < 20000 then
          setLimit = "local"
        elseif 20000 <= varRefNum and varRefNum < 30000 then
          setLimit = "global"
        elseif 30000 <= varRefNum then
          setLimit = "upvalue"
        end
        msgTab.info = this.createSetValueRetTable(varName, newValue, needFindVariable, this.curStackId, nil, setLimit)
      end
      this.sendMsg(msgTab)
      this.debugger_wait_msg()
    end
  elseif dataTable.cmd == "getVariable" then
    if currentRunState == runState.STOP_ON_ENTRY or currentRunState == runState.HIT_BREAKPOINT or currentRunState == runState.STEPOVER_STOP or currentRunState == runState.STEPIN_STOP or currentRunState == runState.STEPOUT_STOP then
      local msgTab = this.getMsgTable("getVariable", this.getCallbackId())
      local varRefNum = tonumber(dataTable.info.varRef)
      if varRefNum < 10000 then
        local varTable = this.getVariableRef(dataTable.info.varRef, true)
        msgTab.info = varTable
      elseif 10000 <= varRefNum and varRefNum < 20000 then
        if dataTable.info.stackId ~= nil and 1 < tonumber(dataTable.info.stackId) then
          this.curStackId = tonumber(dataTable.info.stackId)
          if type(currentCallStack[this.curStackId - 1]) ~= "table" or type(currentCallStack[this.curStackId - 1].func) ~= "function" then
            local str = "getVariable getLocal currentCallStack " .. this.curStackId - 1 .. " Error\n" .. this.serializeTable(currentCallStack, "currentCallStack")
            this.printToVSCode(str, 2)
            msgTab.info = {}
          else
            local stackId = this.getSpecificFunctionStackLevel(currentCallStack[this.curStackId - 1].func)
            local varTable = this.getVariable(stackId, true)
            msgTab.info = varTable
          end
        end
      elseif 20000 <= varRefNum and varRefNum < 30000 then
        local varTable = this.getGlobalVariable()
        msgTab.info = varTable
      elseif 30000 <= varRefNum and dataTable.info.stackId ~= nil and 1 < tonumber(dataTable.info.stackId) then
        this.curStackId = tonumber(dataTable.info.stackId)
        if type(currentCallStack[this.curStackId - 1]) ~= "table" or type(currentCallStack[this.curStackId - 1].func) ~= "function" then
          local str = "getVariable getUpvalue currentCallStack " .. this.curStackId - 1 .. " Error\n" .. this.serializeTable(currentCallStack, "currentCallStack")
          this.printToVSCode(str, 2)
          msgTab.info = {}
        else
          local varTable = this.getUpValueVariable(currentCallStack[this.curStackId - 1].func, true)
          msgTab.info = varTable
        end
      end
      this.sendMsg(msgTab)
      this.debugger_wait_msg()
    end
  elseif dataTable.cmd == "initSuccess" then
    if dataTable.info.isNeedB64EncodeStr == "true" then
      isNeedB64EncodeStr = true
    else
      isNeedB64EncodeStr = false
    end
    luaFileExtension = dataTable.info.luaFileExtension
    local TempFilePath = dataTable.info.TempFilePath
    if TempFilePath:sub(-1, -1) == "\\" or TempFilePath:sub(-1, -1) == "/" then
      TempFilePath = TempFilePath:sub(1, -2)
    end
    TempFilePath_luaString = TempFilePath
    cwd = this.genUnifiedPath(dataTable.info.cwd)
    logLevel = tonumber(dataTable.info.logLevel) or 1
    if dataTable.info.autoPathMode == "true" then
      autoPathMode = true
    else
      autoPathMode = false
    end
    if dataTable.info.pathCaseSensitivity == "true" then
      pathCaseSensitivity = true
    else
      pathCaseSensitivity = false
    end
    if nil == OSType then
      if type(dataTable.info.OSType) == "string" then
        OSType = dataTable.info.OSType
      else
        OSType = "Windows_NT"
        OSTypeErrTip = "未能检测出OSType, 可能是node os库未能加载，系统使用默认设置Windows_NT"
      end
    else
    end
    isUserSetClibPath = false
    if nil == clibPath then
      if type(dataTable.info.clibPath) == "string" then
        clibPath = dataTable.info.clibPath
      else
        clibPath = ""
        pathErrTip = "未能正确获取libpdebug库所在位置, 可能无法加载libpdebug库。"
      end
    else
      isUserSetClibPath = true
    end
    if tostring(dataTable.info.useCHook) == "true" then
      userSetUseClib = true
      if isUserSetClibPath == true then
        if luapanda_chook ~= nil then
          hookLib = luapanda_chook
        elseif not this.tryRequireClib("libpdebug", clibPath) then
          this.printToVSCode("Require clib failed, use Lua to continue debug, use LuaPanda.doctor() for more information.", 1)
        end
      else
        local clibExt, platform
        if OSType == "Darwin" then
          clibExt = "/?.so;"
          platform = "mac"
        elseif OSType == "Linux" then
          clibExt = "/?.so;"
          platform = "linux"
        else
          clibExt = "/?.dll;"
          platform = "win"
        end
        local lua_ver
        if _VERSION == "Lua 5.1" then
          lua_ver = "501"
        else
          lua_ver = "503"
        end
        local x86Path = clibPath .. platform .. "/x86/" .. lua_ver .. clibExt
        local x64Path = clibPath .. platform .. "/x86_64/" .. lua_ver .. clibExt
        if luapanda_chook ~= nil then
          hookLib = luapanda_chook
        elseif not this.tryRequireClib("libpdebug", x64Path) and not this.tryRequireClib("libpdebug", x86Path) then
          this.printToVSCode("Require clib failed, use Lua to continue debug, use LuaPanda.doctor() for more information.", 1)
        end
      end
    else
      userSetUseClib = false
    end
    adapterVer = tostring(dataTable.info.adapterVersion)
    local msgTab = this.getMsgTable("initSuccess", this.getCallbackId())
    local isUseHookLib = 0
    if hookLib ~= nil then
      isUseHookLib = 1
      hookLib.sync_config(logLevel, pathCaseSensitivity and 1 or 0)
      hookLib.sync_tempfile_path(TempFilePath_luaString)
      hookLib.sync_cwd(cwd)
      hookLib.sync_file_ext(luaFileExtension)
    end
    isUseLoadstring = 0
    if debugger_loadString ~= nil and type(debugger_loadString) == "function" and pcall(debugger_loadString("return 0")) then
      isUseLoadstring = 1
    end
    local tab = {
      debuggerVer = tostring(debuggerVer),
      UseHookLib = tostring(isUseHookLib),
      UseLoadstring = tostring(isUseLoadstring),
      isNeedB64EncodeStr = tostring(isNeedB64EncodeStr)
    }
    msgTab.info = tab
    this.sendMsg(msgTab)
    stopOnEntry = dataTable.info.stopOnEntry
    if dataTable.info.stopOnEntry == "true" then
      this.changeRunState(runState.STOP_ON_ENTRY)
    else
      this.debugger_wait_msg(1)
      this.changeRunState(runState.RUN)
    end
  elseif dataTable.cmd == "getWatchedVariable" then
    local msgTab = this.getMsgTable("getWatchedVariable", this.getCallbackId())
    local stackId = tonumber(dataTable.info.stackId)
    if isUseLoadstring == 1 then
      this.curStackId = stackId
      local retValue = this.processWatchedExp(dataTable.info)
      msgTab.info = retValue
      this.sendMsg(msgTab)
      this.debugger_wait_msg()
      return
    else
      local wv = this.getWatchedVariable(dataTable.info.varName, stackId, true)
      if wv ~= nil then
        msgTab.info = wv
      end
      this.sendMsg(msgTab)
      this.debugger_wait_msg()
    end
  elseif dataTable.cmd == "stopRun" then
    local msgTab = this.getMsgTable("stopRun", this.getCallbackId())
    this.sendMsg(msgTab)
    this.disconnect()
  elseif "LuaGarbageCollect" == dataTable.cmd then
    this.printToVSCode("collect garbage!")
    collectgarbage("collect")
    this.sendLuaMemory()
    this.debugger_wait_msg()
  else
    if "runREPLExpression" == dataTable.cmd then
      this.curStackId = tonumber(dataTable.info.stackId)
      local retValue = this.processExp(dataTable.info)
      local msgTab = this.getMsgTable("runREPLExpression", this.getCallbackId())
      msgTab.info = retValue
      this.sendMsg(msgTab)
      this.debugger_wait_msg()
    else
    end
  end
end

function this.createSetValueRetTable(varName, newValue, needFindVariable, curStackId, assigndVar, setLimit)
  local info, getVarRet
  if needFindVariable == false then
    getVarRet = {}
    getVarRet[1] = {
      variablesReference = 0,
      value = newValue,
      name = varName,
      type = type(newValue)
    }
  else
    getVarRet = this.getWatchedVariable(tostring(newValue), curStackId, true)
  end
  if getVarRet ~= nil then
    local realVarValue
    local displayVarValue = getVarRet[1].value
    if needFindVariable == true then
      if 0 < tonumber(getVarRet[1].variablesReference) then
        realVarValue = variableRefTab[tonumber(getVarRet[1].variablesReference)]
      else
        if getVarRet[1].type == "number" then
          realVarValue = tonumber(getVarRet[1].value)
        end
        if getVarRet[1].type == "string" then
          realVarValue = tostring(getVarRet[1].value)
          local first_chr = string.sub(realVarValue, 1, 1)
          local end_chr = string.sub(realVarValue, -1, -1)
          if first_chr == end_chr and (first_chr == "'" or first_chr == "\"") then
            realVarValue = string.sub(realVarValue, 2, -2)
            displayVarValue = realVarValue
          end
        end
        if getVarRet[1].type == "boolean" then
          if getVarRet[1].value == "true" then
            realVarValue = true
          else
            realVarValue = false
          end
        end
        if getVarRet[1].type == "nil" then
          realVarValue = nil
        end
      end
    else
      realVarValue = getVarRet[1].value
    end
    local setVarRet
    if type(assigndVar) ~= table then
      setVarRet = this.setVariableValue(varName, curStackId, realVarValue, setLimit)
    else
      assigndVar[varName] = realVarValue
      setVarRet = true
    end
    if getVarRet[1].type == "string" then
      displayVarValue = "\"" .. displayVarValue .. "\""
    end
    if setVarRet ~= false and setVarRet ~= nil then
      local retTip = "变量 " .. varName .. " 赋值成功"
      info = {
        success = "true",
        name = getVarRet[1].name,
        type = getVarRet[1].type,
        value = displayVarValue,
        variablesReference = tostring(getVarRet[1].variablesReference),
        tip = retTip
      }
    else
      info = {
        success = "false",
        type = type(realVarValue),
        value = displayVarValue,
        tip = "找不到要设置的变量"
      }
    end
  else
    info = {
      success = "false",
      type = nil,
      value = nil,
      tip = "输入的值无意义"
    }
  end
  return info
end

function this.receiveMessage(timeoutSec)
  timeoutSec = timeoutSec or MAX_TIMEOUT_SEC
  sock:settimeout(timeoutSec)
  if 0 < #recvMsgQueue then
    local saved_cmd = recvMsgQueue[1]
    table.remove(recvMsgQueue, 1)
    this.dataProcess(saved_cmd)
    return true
  end
  if currentRunState == runState.DISCONNECT then
    this.disconnect()
    return false
  end
  if sock == nil then
    this.printToConsole("[debugger error]接收信息失败  |  reason: socket == nil", 2)
    return
  end
  local response, err = sock:receive()
  if response == nil then
    if err == "closed" then
      this.printToConsole("[debugger error]接收信息失败  |  reason:" .. err, 2)
      this.disconnect()
    end
    return false
  else
    local proc_response = string.sub(response, 1, -1 * (TCPSplitChar:len() + 1))
    local match_res = string.find(proc_response, TCPSplitChar, 1, true)
    if match_res == nil then
      this.dataProcess(proc_response)
    else
      repeat
        local str1 = string.sub(proc_response, 1, match_res - 1)
        table.insert(recvMsgQueue, str1)
        local str2 = string.sub(proc_response, match_res + TCPSplitChar:len(), -1)
        match_res = string.find(str2, TCPSplitChar, 1, true)
      until not match_res
      this.receiveMessage()
    end
    return true
  end
end

function this.debugger_wait_msg(timeoutSec)
  timeoutSec = timeoutSec or MAX_TIMEOUT_SEC
  if currentRunState == runState.WAIT_CMD then
    local ret = this.receiveMessage(timeoutSec)
    return ret
  end
  if currentRunState == runState.STEPOVER or currentRunState == runState.STEPIN or currentRunState == runState.STEPOUT or currentRunState == runState.RUN then
    this.receiveMessage(0)
    return
  end
  if currentRunState == runState.STEPOVER_STOP or currentRunState == runState.STEPIN_STOP or currentRunState == runState.STEPOUT_STOP or currentRunState == runState.HIT_BREAKPOINT or currentRunState == runState.STOP_ON_ENTRY then
    this.sendLuaMemory()
    this.receiveMessage(MAX_TIMEOUT_SEC)
    return
  end
end

function this.getStackTable(level)
  local functionLevel = 0
  if hookLib ~= nil then
    functionLevel = level or HOOK_LEVEL
  else
    functionLevel = level or this.getSpecificFunctionStackLevel(lastRunFunction.func)
  end
  local stackTab = {}
  local userFuncSteakLevel = 0
  repeat
    local info = debug.getinfo(functionLevel, "SlLnf")
    if info == nil or info.source == "=[C]" then
      break
    end
    local ss = {}
    ss.file = this.getPath(info)
    ss.name = "文件名"
    ss.line = tostring(info.currentline)
    local ssindex = functionLevel - 3
    if hookLib ~= nil then
      ssindex = ssindex + 2
    end
    ss.index = tostring(ssindex)
    table.insert(stackTab, ss)
    local callStackInfo = {}
    callStackInfo.name = ss.file
    callStackInfo.line = ss.line
    callStackInfo.func = info.func
    callStackInfo.realLy = functionLevel
    table.insert(currentCallStack, callStackInfo)
    if userFuncSteakLevel == 0 then
      userFuncSteakLevel = functionLevel
    end
    functionLevel = functionLevel + 1
  until info == nil
  return stackTab, userFuncSteakLevel
end

function this.getPath(info)
  local filePath = info
  if type(info) == "table" then
    filePath = info.source
  end
  local cachePath = this.getCacheFormatPath(filePath)
  if cachePath ~= nil and type(cachePath) == "string" then
    return cachePath
  end
  local originalPath = filePath
  if luaFileExtension ~= "" then
    if string.find(luaFileExtension, "%%%d") then
      filePath = string.gsub(filePath, "%.[%w%.]+$", luaFileExtension)
    else
      filePath = string.gsub(filePath, "%.[%w%.]+$", "")
      filePath = filePath .. "." .. luaFileExtension
    end
  end
  if filePath:sub(1, 1) == "@" then
    filePath = filePath:sub(2)
  end
  if not autoPathMode then
    if filePath:sub(1, 1) == "/" or filePath:sub(1, 2):match("^%a:") then
      isAbsolutePath = true
    else
      isAbsolutePath = false
      if cwd ~= "" then
        local matchRes = string.find(filePath, cwd, 1, true)
        if matchRes == nil then
          filePath = cwd .. "/" .. filePath
        end
      end
    end
  end
  filePath = this.genUnifiedPath(filePath)
  if autoPathMode then
    filePath = this.getFilenameFromPath(filePath)
  end
  this.setCacheFormatPath(originalPath, filePath)
  return filePath
end

function this.getFilenameFromPath(path)
  if path == nil then
    return ""
  end
  return string.match(path, "([^/]*)$")
end

function this.getCurrentFunctionStackLevel()
  local funclayer = 2
  repeat
    local info = debug.getinfo(funclayer, "S")
    if info ~= nil then
      local matchRes = info.source == DebuggerFileName or info.source == DebuggerToolsName
      if matchRes == false then
        return funclayer - 1
      end
    end
    funclayer = funclayer + 1
  until not info
  return 0
end

function this.getSpecificFunctionStackLevel(func)
  local funclayer = 2
  repeat
    local info = debug.getinfo(funclayer, "f")
    if info ~= nil and info.func == func then
      return funclayer - 1
    end
    funclayer = funclayer + 1
  until not info
  return 0
end

function this.checkCurrentLayerisLua(checkLayer)
  local info = debug.getinfo(checkLayer, "S")
  if info == nil then
    return nil
  end
  info.source = this.genUnifiedPath(info.source)
  if info ~= nil then
    for k, v in pairs(info) do
      if k == "what" then
        if v == "C" then
          return false
        else
          return true
        end
      end
    end
  end
  return nil
end

function this.isHitBreakpoint(info)
  local curLine = tostring(info.currentline)
  local breakpointPath = info.source
  local isPathHit = false
  if breaks[breakpointPath] then
    isPathHit = true
  end
  if isPathHit then
    for k, v in ipairs(breaks[breakpointPath]) do
      if tostring(v.line) == tostring(curLine) then
        if v.type == "0" then
          local conditionRet = this.IsMeetCondition(v.condition)
          return conditionRet
        elseif v.type == "1" then
          this.printToVSCode("[log point output]: " .. v.logMessage, 1)
        else
          return true
        end
      end
    end
  end
  return false
end

function this.IsMeetCondition(conditionExp)
  currentCallStack = {}
  variableRefTab = {}
  variableRefIdx = 1
  this.getStackTable()
  this.curStackId = 2
  local conditionExpTable = {varName = conditionExp}
  local retTable = this.processWatchedExp(conditionExpTable)
  local isMeetCondition = false
  
  local function HandleResult()
    if retTable[1].isSuccess == "true" then
      if retTable[1].value == "nil" or retTable[1].value == "false" and retTable[1].type == "boolean" then
        isMeetCondition = false
      else
        isMeetCondition = true
      end
    else
      isMeetCondition = false
    end
  end
  
  xpcall(HandleResult, function()
    isMeetCondition = false
  end)
  return isMeetCondition
end

function this.BP()
  this.printToConsole("BP()")
  if hookLib == nil then
    if currentHookState == hookState.DISCONNECT_HOOK then
      this.printToConsole("BP() but NO HOOK")
      return
    end
    local co, isMain = coroutine.running()
    if _VERSION == "Lua 5.1" then
      if co == nil then
        isMain = true
      else
        isMain = false
      end
    end
    if isMain == true then
      this.printToConsole("BP() in main")
    else
      this.printToConsole("BP() in coroutine")
      debug.sethook(co, this.debug_hook, "lrc")
    end
    hitBP = true
  else
    if hookLib.get_libhook_state() == hookState.DISCONNECT_HOOK then
      this.printToConsole("BP() but NO C HOOK")
      return
    end
    hookLib.sync_bp_hit(1)
  end
  this.changeHookState(hookState.ALL_HOOK)
  return true
end

function this.checkHasBreakpoint(fileName)
  local hasBk = false
  if next(breaks) == nil then
    hasBk = false
  else
    hasBk = true
  end
  if fileName ~= nil then
    return breaks[fileName] ~= nil, hasBk
  else
    return hasBk
  end
end

function this.checkfuncHasBreakpoint(sLine, eLine, fileName)
  if breaks[fileName] == nil then
    return false
  end
  sLine = tonumber(sLine)
  eLine = tonumber(eLine)
  if sLine >= eLine then
    return true
  end
  if #breaks[fileName] <= 0 then
    return false
  else
    for k, v in ipairs(breaks[fileName]) do
      if sLine < tonumber(v.line) and eLine >= tonumber(v.line) then
        return true
      end
    end
  end
  return false
end

function this.debug_hook(event, line)
  if this.reConnect() == 1 then
    return
  end
  if logLevel == 0 then
    local logTable = {
      "-----enter debug_hook-----\n",
      "event:",
      event,
      "  line:",
      tostring(line),
      " currentHookState:",
      currentHookState,
      " currentRunState:",
      currentRunState
    }
    local logString = table.concat(logTable)
    this.printToVSCode(logString)
  end
  if currentHookState == hookState.LITE_HOOK then
    local ti = os.time()
    if 1 < ti - receiveMsgTimer then
      this.debugger_wait_msg(0)
      receiveMsgTimer = ti
    end
    return
  end
  local info
  local co, isMain = coroutine.running()
  if _VERSION == "Lua 5.1" then
    if co == nil then
      isMain = true
    else
      isMain = false
    end
  end
  isInMainThread = isMain
  if isMain == true then
    info = debug.getinfo(2, "Slf")
  else
    info = debug.getinfo(co, 2, "Slf")
  end
  info.event = event
  this.real_hook_process(info)
end

function this.real_hook_process(info)
  local jumpFlag = false
  local event = info.event
  local matchRes = info.source == DebuggerFileName or info.source == DebuggerToolsName
  if matchRes == true then
    return
  end
  if currentRunState == runState.RUN or currentRunState == runState.STEPOVER or currentRunState == runState.STEPIN or currentRunState == runState.STEPOUT then
    local ti = os.time()
    if 1 < ti - receiveMsgTimer then
      this.debugger_wait_msg(0)
      receiveMsgTimer = ti
    end
  end
  if info.source == "=[C]" then
    this.printToVSCode("current method is C")
    return
  end
  if info.source == "temp buffer" then
    this.printToVSCode("current method is in temp buffer")
    return
  end
  if info.source == "chunk" then
    this.printToVSCode("current method is in chunk")
    return
  end
  if info.short_src:match("%[string \"") and info.source:match([=[
[
;=]]=]) then
    this.printToVSCode("hook jump Code String!")
    jumpFlag = true
  end
  if jumpFlag == false then
    info.source = this.getPath(info)
  end
  if lastRunFunction.currentline == info.currentline and lastRunFunction.source == info.source and lastRunFunction.func == info.func and lastRunFunction.event == event then
    this.printToVSCode("run twice")
  end
  if jumpFlag == false then
    lastRunFunction = info
    lastRunFunction.event = event
    lastRunFilePath = info.source
  end
  if logLevel == 0 and jumpFlag == false then
    local logTable = {
      "[lua hook] event:",
      tostring(event),
      " currentRunState:",
      tostring(currentRunState),
      " currentHookState:",
      tostring(currentHookState),
      " jumpFlag:",
      tostring(jumpFlag)
    }
    for k, v in pairs(info) do
      table.insert(logTable, tostring(k))
      table.insert(logTable, ":")
      table.insert(logTable, tostring(v))
      table.insert(logTable, " ")
    end
    local logString = table.concat(logTable)
    this.printToVSCode(logString)
  end
  local isHit = false
  if tostring(event) == "line" and jumpFlag == false and (currentRunState == runState.RUN or currentRunState == runState.STEPOVER or currentRunState == runState.STEPIN or currentRunState == runState.STEPOUT) then
    isHit = this.isHitBreakpoint(info) or hitBP
    if isHit == true then
      this.printToVSCode(" + HitBreakpoint true")
      hitBP = false
      stepOverCounter = 0
      stepOutCounter = 0
      this.changeRunState(runState.HIT_BREAKPOINT)
      this.SendMsgWithStack("stopOnBreakpoint")
    end
  end
  if isHit == true then
    return
  end
  if currentRunState == runState.STEPOVER then
    if event == "line" and stepOverCounter <= 0 and jumpFlag == false then
      stepOverCounter = 0
      this.changeRunState(runState.STEPOVER_STOP)
      this.SendMsgWithStack("stopOnStep")
    elseif event == "return" or event == "tail return" then
      if stepOverCounter ~= 0 then
        stepOverCounter = stepOverCounter - 1
      end
    elseif event == "call" then
      stepOverCounter = stepOverCounter + 1
    end
  elseif currentRunState == runState.STOP_ON_ENTRY then
    if event == "line" and jumpFlag == false then
      this.SendMsgWithStack("stopOnEntry")
    end
  elseif currentRunState == runState.STEPIN then
    if event == "line" and jumpFlag == false then
      this.changeRunState(runState.STEPIN_STOP)
      this.SendMsgWithStack("stopOnStepIn")
    end
  elseif currentRunState == runState.STEPOUT then
    if jumpFlag == false and stepOutCounter <= -1 then
      stepOutCounter = 0
      this.changeRunState(runState.STEPOUT_STOP)
      this.SendMsgWithStack("stopOnStepOut")
    end
    if event == "return" or event == "tail return" then
      stepOutCounter = stepOutCounter - 1
    elseif event == "call" then
      stepOutCounter = stepOutCounter + 1
    end
  end
  if hookLib == nil and currentRunState == runState.RUN and jumpFlag == false and currentHookState ~= hookState.DISCONNECT_HOOK then
    local fileBP, G_BP = this.checkHasBreakpoint(lastRunFilePath)
    if fileBP == false then
      if G_BP == true then
        this.changeHookState(hookState.MID_HOOK)
      else
        this.changeHookState(hookState.LITE_HOOK)
      end
    else
      local funHasBP = this.checkfuncHasBreakpoint(lastRunFunction.linedefined, lastRunFunction.lastlinedefined, lastRunFilePath)
      if funHasBP then
        this.changeHookState(hookState.ALL_HOOK)
      else
        this.changeHookState(hookState.MID_HOOK)
      end
    end
    if (event == "return" or event == "tail return") and currentHookState == hookState.MID_HOOK then
      this.changeHookState(hookState.ALL_HOOK)
    end
  end
end

function this.SendMsgWithStack(cmdStr)
  local msgTab = this.getMsgTable(cmdStr)
  local userFuncLevel = 0
  msgTab.stack, userFuncLevel = this.getStackTable()
  if userFuncLevel ~= 0 then
    lastRunFunction.func = debug.getinfo(userFuncLevel - 1, "f").func
  end
  this.sendMsg(msgTab)
  this.debugger_wait_msg()
end

function this.changeHookState(s)
  if hookLib == nil and currentHookState == s then
    return
  end
  this.printToConsole("change hook state :" .. s)
  if s ~= hookState.DISCONNECT_HOOK then
    this.printToVSCode("change hook state : " .. s)
  end
  currentHookState = s
  if s == hookState.DISCONNECT_HOOK then
    if openAttachMode == true then
      if hookLib then
        hookLib.lua_set_hookstate(hookState.DISCONNECT_HOOK)
      else
        debug.sethook(this.debug_hook, "r", 1000000)
      end
    elseif hookLib then
      hookLib.endHook()
    else
      debug.sethook()
    end
  elseif s == hookState.LITE_HOOK then
    if hookLib then
      hookLib.lua_set_hookstate(hookState.LITE_HOOK)
    else
      debug.sethook(this.debug_hook, "r")
    end
  elseif s == hookState.MID_HOOK then
    if hookLib then
      hookLib.lua_set_hookstate(hookState.MID_HOOK)
    else
      debug.sethook(this.debug_hook, "rc")
    end
  elseif s == hookState.ALL_HOOK then
    if hookLib then
      hookLib.lua_set_hookstate(hookState.ALL_HOOK)
    else
      debug.sethook(this.debug_hook, "lrc")
    end
  end
  if hookLib == nil then
    this.changeCoroutineHookState()
  end
end

function this.changeRunState(s, isFromHooklib)
  local msgFrom
  if isFromHooklib == 1 then
    msgFrom = "libc"
  else
    msgFrom = "lua"
  end
  this.printToConsole("changeRunState :" .. s .. " | from:" .. msgFrom)
  if s ~= runState.DISCONNECT and s ~= runState.WAIT_CMD then
    this.printToVSCode("changeRunState :" .. s .. " | from:" .. msgFrom)
  end
  if hookLib ~= nil and isFromHooklib ~= 1 then
    hookLib.lua_set_runstate(s)
  end
  currentRunState = s
  currentCallStack = {}
  variableRefTab = {}
  variableRefIdx = 1
end

function this.changeCoroutineHookState(s)
  s = s or currentHookState
  this.printToConsole("change [Coroutine] HookState: " .. tostring(s))
  for k, co in pairs(coroutinePool) do
    if coroutine.status(co) == "dead" then
      table.remove(coroutinePool, k)
    elseif s == hookState.DISCONNECT_HOOK then
      if openAttachMode == true then
        debug.sethook(co, this.debug_hook, "r", 1000000)
      else
        debug.sethook(co, this.debug_hook, "")
      end
    elseif s == hookState.LITE_HOOK then
      debug.sethook(co, this.debug_hook, "r")
    elseif s == hookState.MID_HOOK then
      debug.sethook(co, this.debug_hook, "rc")
    elseif s == hookState.ALL_HOOK then
      debug.sethook(co, this.debug_hook, "lrc")
    end
  end
end

function this.clearEnv()
  if this.getTableMemberNum(env) > 0 then
    env = setmetatable({}, getmetatable(env))
  end
end

function this.showEnv()
  return env
end

function this.findTableVar(tableVarName, realVar)
  if type(tableVarName) ~= "table" or type(realVar) ~= "table" then
    return nil
  end
  local layer = 2
  local curVar = realVar
  local jumpOutFlag = false
  repeat
    if tableVarName[layer] ~= nil then
      local tmpCurVar
      xpcall(function()
        tmpCurVar = curVar[tonumber(tableVarName[layer])]
      end, function()
        tmpCurVar = nil
      end)
      if tmpCurVar == nil then
        xpcall(function()
          curVar = curVar[tostring(tableVarName[layer])]
        end, function()
          curVar = nil
        end)
      else
        curVar = tmpCurVar
      end
      layer = layer + 1
      if curVar == nil then
        return nil
      end
    else
      jumpOutFlag = true
    end
  until jumpOutFlag == true
  return curVar
end

function this.createWatchedVariableInfo(variableName, variableIns)
  local var = {}
  var.name = variableName
  var.type = tostring(type(variableIns))
  xpcall(function()
    var.value = tostring(variableIns)
  end, function()
    var.value = tostring(type(variableIns)) .. " [value can't trans to string]"
  end)
  var.variablesReference = "0"
  if var.type == "table" or var.type == "function" or var.type == "userdata" then
    var.variablesReference = variableRefIdx
    variableRefTab[variableRefIdx] = variableIns
    variableRefIdx = variableRefIdx + 1
    if var.type == "table" then
      local memberNum = this.getTableMemberNum(variableIns)
      var.value = memberNum .. " Members " .. var.value
    end
  elseif var.type == "string" then
    var.value = "\"" .. variableIns .. "\""
  end
  return var
end

function this.setGlobal(varName, newValue)
  _G[varName] = newValue
  this.printToVSCode("[setVariable success] 已设置  _G." .. varName .. " = " .. tostring(newValue))
  return true
end

function this.setUpvalue(varName, newValue, stackId, tableVarName)
  local ret = false
  local upTable = this.getUpValueVariable(currentCallStack[stackId - 1].func, true)
  for i, realVar in ipairs(upTable) do
    if realVar.name == varName then
      if 0 < #tableVarName and type(realVar) == "table" then
        local findRes = this.findTableVar(tableVarName, variableRefTab[realVar.variablesReference])
        if findRes ~= nil then
          local setVarRet = debug.setupvalue(currentCallStack[stackId - 1].func, i, newValue)
          if setVarRet == varName then
            this.printToConsole("[setVariable success1] 已设置 upvalue " .. varName .. " = " .. tostring(newValue))
            ret = true
          else
            this.printToConsole("[setVariable error1] 未能设置 upvalue " .. varName .. " = " .. tostring(newValue) .. " , 返回结果: " .. tostring(setVarRet))
          end
          return ret
        end
      else
        local setVarRet = debug.setupvalue(currentCallStack[stackId - 1].func, i, newValue)
        if setVarRet == varName then
          this.printToConsole("[setVariable success] 已设置 upvalue " .. varName .. " = " .. tostring(newValue))
          ret = true
        else
          this.printToConsole("[setVariable error] 未能设置 upvalue " .. varName .. " = " .. tostring(newValue) .. " , 返回结果: " .. tostring(setVarRet))
        end
        return ret
      end
    end
  end
  return ret
end

function this.setLocal(varName, newValue, tableVarName, stackId)
  local istackId = tonumber(stackId)
  local offset = istackId and istackId - 2 or 0
  local layerVarTab, ly = this.getVariable(nil, true, offset)
  local ret = false
  for i, realVar in ipairs(layerVarTab) do
    if realVar.name == varName then
      if 0 < #tableVarName and type(realVar) == "table" then
        local findRes = this.findTableVar(tableVarName, variableRefTab[realVar.variablesReference])
        if findRes ~= nil then
          local setVarRet = debug.setlocal(ly, layerVarTab[i].index, newValue)
          if setVarRet == varName then
            this.printToConsole("[setVariable success1] 已设置 local " .. varName .. " = " .. tostring(newValue))
            ret = true
          else
            this.printToConsole("[setVariable error1] 未能设置 local " .. varName .. " = " .. tostring(newValue) .. " , 返回结果: " .. tostring(setVarRet))
          end
          return ret
        end
      else
        local setVarRet = debug.setlocal(ly, layerVarTab[i].index, newValue)
        if setVarRet == varName then
          this.printToConsole("[setVariable success] 已设置 local " .. varName .. " = " .. tostring(newValue))
          ret = true
        else
          this.printToConsole("[setVariable error] 未能设置 local " .. varName .. " = " .. tostring(newValue) .. " , 返回结果: " .. tostring(setVarRet))
        end
        return ret
      end
    end
  end
  return ret
end

function this.setVariableValue(varName, stackId, newValue, limit)
  this.printToConsole("setVariableValue | varName:" .. tostring(varName) .. " stackId:" .. tostring(stackId) .. " newValue:" .. tostring(newValue) .. " limit:" .. tostring(limit))
  if tostring(varName) == nil or tostring(varName) == "" then
    this.printToConsole("[setVariable Error] 被赋值的变量名为空", 2)
    this.printToVSCode("[setVariable Error] 被赋值的变量名为空", 2)
    return false
  end
  local tableVarName = {}
  if varName:match("%.") then
    tableVarName = this.stringSplit(varName, "%.")
    if type(tableVarName) ~= "table" or #tableVarName < 1 then
      return false
    end
    varName = tableVarName[1]
  end
  if limit == "local" then
    local ret = this.setLocal(varName, newValue, tableVarName, stackId)
    return ret
  elseif limit == "upvalue" then
    local ret = this.setUpvalue(varName, newValue, stackId, tableVarName)
    return ret
  elseif limit == "global" then
    local ret = this.setGlobal(varName, newValue)
    return ret
  else
    local ret = this.setLocal(varName, newValue, tableVarName, stackId) or this.setUpvalue(varName, newValue, stackId, tableVarName) or this.setGlobal(varName, newValue)
    this.printToConsole("set Value res :" .. tostring(ret))
    return ret
  end
end

function this.getWatchedVariable(varName, stackId, isFormatVariable)
  this.printToConsole("getWatchedVariable | varName:" .. tostring(varName) .. " stackId:" .. tostring(stackId) .. " isFormatVariable:" .. tostring(isFormatVariable))
  if tostring(varName) == nil or tostring(varName) == "" then
    return nil
  end
  if type(currentCallStack[stackId - 1]) ~= "table" or type(currentCallStack[stackId - 1].func) ~= "function" then
    local str = "getWatchedVariable currentCallStack " .. stackId - 1 .. " Error\n" .. this.serializeTable(currentCallStack, "currentCallStack")
    this.printToVSCode(str, 2)
    return nil
  end
  local orgname = varName
  local tableVarName = {}
  if varName:match("%.") then
    tableVarName = this.stringSplit(varName, "%.")
    if type(tableVarName) ~= "table" or #tableVarName < 1 then
      return nil
    end
    varName = tableVarName[1]
  end
  local varTab = {}
  local ly = this.getSpecificFunctionStackLevel(currentCallStack[stackId - 1].func)
  local layerVarTab = this.getVariable(ly, isFormatVariable)
  local upTable = this.getUpValueVariable(currentCallStack[stackId - 1].func, isFormatVariable)
  local travelTab = {}
  table.insert(travelTab, layerVarTab)
  table.insert(travelTab, upTable)
  for _, layerVarTab in ipairs(travelTab) do
    for i, realVar in ipairs(layerVarTab) do
      if realVar.name == varName then
        if 0 < #tableVarName and type(realVar) == "table" then
          local findRes = this.findTableVar(tableVarName, variableRefTab[realVar.variablesReference])
          if findRes ~= nil then
            if isFormatVariable then
              local var = this.createWatchedVariableInfo(orgname, findRes)
              table.insert(varTab, var)
              return varTab
            else
              return findRes.value
            end
          end
        elseif isFormatVariable then
          table.insert(varTab, realVar)
          return varTab
        else
          return realVar.value
        end
      end
    end
  end
  if _G[varName] ~= nil then
    if 0 < #tableVarName and type(_G[varName]) == "table" then
      local findRes = this.findTableVar(tableVarName, _G[varName])
      if findRes ~= nil then
        if isFormatVariable then
          local var = this.createWatchedVariableInfo(orgname, findRes)
          table.insert(varTab, var)
          return varTab
        else
          return findRes
        end
      end
    elseif isFormatVariable then
      local var = this.createWatchedVariableInfo(varName, _G[varName])
      table.insert(varTab, var)
      return varTab
    else
      return _G[varName]
    end
  end
  this.printToConsole("getWatchedVariable not find variable")
  return nil
end

function this.getVariableRef(refStr)
  local varRef = tonumber(refStr)
  local varTab = {}
  if tostring(type(variableRefTab[varRef])) == "table" then
    for n, v in pairs(variableRefTab[varRef]) do
      local var = {}
      if type(n) == "string" then
        var.name = "\"" .. tostring(n) .. "\""
      else
        var.name = tostring(n)
      end
      var.type = tostring(type(v))
      xpcall(function()
        var.value = tostring(v)
      end, function()
        var.value = tostring(type(v)) .. " [value can't trans to string]"
      end)
      var.variablesReference = "0"
      if var.type == "table" or var.type == "function" or var.type == "userdata" then
        var.variablesReference = variableRefIdx
        variableRefTab[variableRefIdx] = v
        variableRefIdx = variableRefIdx + 1
        if var.type == "table" then
          local memberNum = this.getTableMemberNum(v)
          var.value = memberNum .. " Members " .. (var.value or "")
        end
      elseif var.type == "string" then
        var.value = "\"" .. v .. "\""
      end
      table.insert(varTab, var)
    end
    local mtTab = getmetatable(variableRefTab[varRef])
    if mtTab ~= nil and type(mtTab) == "table" then
      do
        local var = {}
        var.name = "_Metatable_"
        var.type = tostring(type(mtTab))
        xpcall(function()
          var.value = "元表 " .. tostring(mtTab)
        end, function()
          var.value = "元表 [value can't trans to string]"
        end)
        var.variablesReference = variableRefIdx
        variableRefTab[variableRefIdx] = mtTab
        variableRefIdx = variableRefIdx + 1
        table.insert(varTab, var)
      end
    end
  elseif tostring(type(variableRefTab[varRef])) == "function" then
    varTab = this.getUpValueVariable(variableRefTab[varRef], true)
  elseif tostring(type(variableRefTab[varRef])) == "userdata" then
    local udMtTable = getmetatable(variableRefTab[varRef])
    if udMtTable ~= nil and type(udMtTable) == "table" then
      do
        local var = {}
        var.name = "_Metatable_"
        var.type = tostring(type(udMtTable))
        xpcall(function()
          var.value = "元表 " .. tostring(udMtTable)
        end, function()
          var.value = "元表 [value can't trans to string]"
        end)
        var.variablesReference = variableRefIdx
        variableRefTab[variableRefIdx] = udMtTable
        variableRefIdx = variableRefIdx + 1
        table.insert(varTab, var)
        if udMtTable.__pairs ~= nil and type(udMtTable.__pairs) == "function" then
          for n, v in pairs(variableRefTab[varRef]) do
            local var = {}
            var.name = tostring(n)
            var.type = tostring(type(v))
            xpcall(function()
              var.value = tostring(v)
            end, function()
              var.value = tostring(type(v)) .. " [value can't trans to string]"
            end)
            var.variablesReference = "0"
            if var.type == "table" or var.type == "function" or var.type == "userdata" then
              var.variablesReference = variableRefIdx
              variableRefTab[variableRefIdx] = v
              variableRefIdx = variableRefIdx + 1
              if var.type == "table" then
                local memberNum = this.getTableMemberNum(v)
                var.value = memberNum .. " Members " .. (var.value or "")
              end
            elseif var.type == "string" then
              var.value = "\"" .. v .. "\""
            end
            table.insert(varTab, var)
          end
        end
      end
    end
  end
  return varTab
end

function this.getGlobalVariable(...)
  local varTab = {}
  for k, v in pairs(_G) do
    local var = {}
    var.name = tostring(k)
    var.type = tostring(type(v))
    xpcall(function()
      var.value = tostring(v)
    end, function()
      var.value = tostring(type(v)) .. " [value can't trans to string]"
    end)
    var.variablesReference = "0"
    if var.type == "table" or var.type == "function" or var.type == "userdata" then
      var.variablesReference = variableRefIdx
      variableRefTab[variableRefIdx] = v
      variableRefIdx = variableRefIdx + 1
      if var.type == "table" then
        local memberNum = this.getTableMemberNum(v)
        var.value = memberNum .. " Members " .. (var.value or "")
      end
    elseif var.type == "string" then
      var.value = "\"" .. v .. "\""
    end
    table.insert(varTab, var)
  end
  return varTab
end

function this.getUpValueVariable(checkFunc, isFormatVariable)
  local isGetValue = true
  if isFormatVariable == true then
    isGetValue = false
  end
  checkFunc = checkFunc or lastRunFunction.func
  local varTab = {}
  if checkFunc == nil then
    return varTab
  end
  local i = 1
  repeat
    local n, v = debug.getupvalue(checkFunc, i)
    if n then
      local var = {}
      var.name = n
      var.type = tostring(type(v))
      var.variablesReference = "0"
      if isGetValue == false then
        xpcall(function()
          var.value = tostring(v)
        end, function()
          var.value = tostring(type(v)) .. " [value can't trans to string]"
        end)
        if var.type == "table" or var.type == "function" or var.type == "userdata" then
          var.variablesReference = variableRefIdx
          variableRefTab[variableRefIdx] = v
          variableRefIdx = variableRefIdx + 1
          if var.type == "table" then
            local memberNum = this.getTableMemberNum(v)
            var.value = memberNum .. " Members " .. (var.value or "")
          end
        elseif var.type == "string" then
          var.value = "\"" .. v .. "\""
        end
      else
        var.value = v
      end
      table.insert(varTab, var)
      i = i + 1
    end
  until not n
  return varTab
end

function this.getVariable(checkLayer, isFormatVariable, offset)
  local isGetValue = true
  if isFormatVariable == true then
    isGetValue = false
  end
  local ly = 0
  if checkLayer ~= nil and type(checkLayer) == "number" then
    ly = checkLayer + 1
  else
    ly = this.getSpecificFunctionStackLevel(lastRunFunction.func)
  end
  if ly == 0 then
    this.printToVSCode("[error]获取层次失败！", 2)
    return
  end
  local varTab = {}
  local stacklayer = ly
  local k = 1
  if type(offset) == "number" then
    stacklayer = stacklayer + offset
  end
  repeat
    local n, v = debug.getlocal(stacklayer, k)
    if n == nil then
      goto lbl_122
    end
    if "(*temporary)" ~= tostring(n) then
      local var = {}
      var.name = n
      var.type = tostring(type(v))
      var.variablesReference = "0"
      var.index = k
      if isGetValue == false then
        xpcall(function()
          var.value = tostring(v)
        end, function()
          var.value = tostring(type(v)) .. " [value can't trans to string]"
        end)
        if var.type == "table" or var.type == "function" or var.type == "userdata" then
          var.variablesReference = variableRefIdx
          variableRefTab[variableRefIdx] = v
          variableRefIdx = variableRefIdx + 1
          if var.type == "table" then
            local memberNum = this.getTableMemberNum(v)
            var.value = memberNum .. " Members " .. (var.value or "")
          end
        elseif var.type == "string" then
          var.value = "\"" .. v .. "\""
        end
      else
        var.value = v
      end
      local sameIdx = this.checkSameNameVar(varTab, var)
      if sameIdx ~= 0 then
        varTab[sameIdx] = var
      else
        table.insert(varTab, var)
      end
    end
    k = k + 1
  until n == nil
  ::lbl_122::
  return varTab, stacklayer - 1
end

function this.checkSameNameVar(varTab, var)
  for k, v in pairs(varTab) do
    if v.name == var.name then
      return k
    end
  end
  return 0
end

function this.processExp(msgTable)
  local retString
  local var = {}
  var.isSuccess = "true"
  if msgTable ~= nil then
    local expression = this.trim(tostring(msgTable.Expression))
    local isCmd = false
    if isCmd == false then
      if expression:find("p ", 1, true) == 1 then
        expression = expression:sub(3)
      end
      local expressionWithReturn = "return " .. expression
      local f = debugger_loadString(expressionWithReturn) or debugger_loadString(expression)
      if type(f) == "function" then
        if _VERSION == "Lua 5.1" then
          setfenv(f, env)
        else
          debug.setupvalue(f, 1, env)
        end
        xpcall(function()
          retString = f()
        end, function()
          retString = "输入错误指令。\n + 请检查指令是否正确\n + 指令仅能在[暂停在断点时]输入, 请不要在程序持续运行时输入"
          var.isSuccess = false
        end)
      else
        retString = "指令执行错误。\n + 请检查指令是否正确\n + 可以直接输入表达式，执行函数或变量名，并观察执行结果"
        var.isSuccess = false
      end
    end
  end
  var.name = "Exp"
  var.type = tostring(type(retString))
  xpcall(function()
    var.value = tostring(retString)
  end, function(e)
    var.value = tostring(type(retString)) .. " [value can't trans to string] " .. e
    var.isSuccess = false
  end)
  var.variablesReference = "0"
  if var.type == "table" or var.type == "function" or var.type == "userdata" then
    variableRefTab[variableRefIdx] = retString
    var.variablesReference = variableRefIdx
    variableRefIdx = variableRefIdx + 1
    if var.type == "table" then
      local memberNum = this.getTableMemberNum(retString)
      var.value = memberNum .. " Members " .. var.value
    end
  elseif var.type == "string" then
    var.value = "\"" .. retString .. "\""
  end
  this.clearEnv()
  local retTab = {}
  table.insert(retTab, var)
  return retTab
end

function this.processWatchedExp(msgTable)
  local retString
  local expression = "return " .. tostring(msgTable.varName)
  this.printToConsole("processWatchedExp | expression: " .. expression)
  local f = debugger_loadString(expression)
  local var = {}
  var.isSuccess = "true"
  if type(f) == "function" then
    if _VERSION == "Lua 5.1" then
      setfenv(f, env)
    else
      debug.setupvalue(f, 1, env)
    end
    xpcall(function()
      retString = f()
    end, function()
      retString = "输入了错误的变量信息"
      var.isSuccess = "false"
    end)
  else
    retString = "未能找到变量的值"
    var.isSuccess = "false"
  end
  var.name = msgTable.varName
  var.type = tostring(type(retString))
  xpcall(function()
    var.value = tostring(retString)
  end, function()
    var.value = tostring(type(retString)) .. " [value can't trans to string]"
    var.isSuccess = "false"
  end)
  var.variablesReference = "0"
  if var.type == "table" or var.type == "function" or var.type == "userdata" then
    variableRefTab[variableRefIdx] = retString
    var.variablesReference = variableRefIdx
    variableRefIdx = variableRefIdx + 1
    if var.type == "table" then
      local memberNum = this.getTableMemberNum(retString)
      var.value = memberNum .. " Members " .. var.value
    end
  elseif var.type == "string" then
    var.value = "\"" .. retString .. "\""
  end
  local retTab = {}
  table.insert(retTab, var)
  return retTab
end

function tools.getFileSource()
  local info = debug.getinfo(1, "S")
  for k, v in pairs(info) do
    if k == "source" then
      return v
    end
  end
end

function tools.printTable(t, name, indent)
  local str = tools.show(t, name, indent)
  print(str)
end

function tools.serializeTable(t, name, indent)
  local str = tools.show(t, name, indent)
  return str
end

function tools.show(t, name, indent)
  local cart, autoref
  
  local function isemptytable(t)
    return next(t) == nil
  end
  
  local function basicSerialize(o)
    local so = tostring(o)
    if type(o) == "function" then
      local info = debug.getinfo(o, "S")
      if info.what == "C" then
        return string.format("%q", so .. ", C function")
      else
        return string.format("%q", so .. ", defined in (" .. info.linedefined .. "-" .. info.lastlinedefined .. ")" .. info.source)
      end
    elseif type(o) == "number" or type(o) == "boolean" then
      return so
    else
      return string.format("%q", so)
    end
  end
  
  local function addtocart(value, name, indent, saved, field)
    indent = indent or ""
    saved = saved or {}
    field = field or name
    cart = cart .. indent .. field
    if type(value) ~= "table" then
      cart = cart .. " = " .. basicSerialize(value) .. ";\n"
    elseif saved[value] then
      cart = cart .. " = {}; -- " .. saved[value] .. " (self reference)\n"
      autoref = autoref .. name .. " = " .. saved[value] .. ";\n"
    else
      saved[value] = name
      if isemptytable(value) then
        cart = cart .. " = {};\n"
      else
        cart = cart .. " = {\n"
        for k, v in pairs(value) do
          k = basicSerialize(k)
          local fname = string.format("%s[%s]", name, k)
          field = string.format("[%s]", k)
          addtocart(v, fname, indent .. "   ", saved, field)
        end
        cart = cart .. indent .. "};\n"
      end
    end
  end
  
  name = name or "PRINT_Table"
  if type(t) ~= "table" then
    return name .. " = " .. basicSerialize(t)
  end
  cart, autoref = "", ""
  addtocart(t, name, indent)
  return cart .. autoref
end

function tools.createJson()
  local math = require("math")
  local string = require("string")
  local table = require("table")
  local json = {}
  local json_private = {}
  json.EMPTY_ARRAY = {}
  json.EMPTY_OBJECT = {}
  local decode_scanArray, decode_scanComment, decode_scanConstant, decode_scanNumber, decode_scanObject, decode_scanString, decode_scanWhitespace, encodeString, isArray, isEncodable
  
  function json.encode(v)
    if v == nil then
      return "null"
    end
    local vtype = type(v)
    if vtype == "string" then
      return "\"" .. json_private.encodeString(v) .. "\""
    end
    if vtype == "number" or vtype == "boolean" then
      return tostring(v)
    end
    if vtype == "table" then
      local rval = {}
      local bArray, maxCount = isArray(v)
      if bArray then
        for i = 1, maxCount do
          table.insert(rval, json.encode(v[i]))
        end
      else
        for i, j in pairs(v) do
          if isEncodable(i) and isEncodable(j) then
            table.insert(rval, "\"" .. json_private.encodeString(i) .. "\":" .. json.encode(j))
          end
        end
      end
      if bArray then
        return "[" .. table.concat(rval, ",") .. "]"
      else
        return "{" .. table.concat(rval, ",") .. "}"
      end
    end
    if vtype == "function" and v == json.null then
      return "null"
    end
    assert(false, "encode attempt to encode unsupported type " .. vtype .. ":" .. tostring(v))
  end
  
  function json.decode(s, startPos)
    startPos = startPos and startPos or 1
    startPos = decode_scanWhitespace(s, startPos)
    assert(startPos <= string.len(s), "Unterminated JSON encoded object found at position in [" .. s .. "]")
    local curChar = string.sub(s, startPos, startPos)
    if curChar == "{" then
      return decode_scanObject(s, startPos)
    end
    if curChar == "[" then
      return decode_scanArray(s, startPos)
    end
    if string.find("+-0123456789.e", curChar, 1, true) then
      return decode_scanNumber(s, startPos)
    end
    if curChar == "\"" or curChar == "'" then
      return decode_scanString(s, startPos)
    end
    if string.sub(s, startPos, startPos + 1) == "/*" then
      return json.decode(s, decode_scanComment(s, startPos))
    end
    return decode_scanConstant(s, startPos)
  end
  
  function json.null()
    return json.null
  end
  
  function decode_scanArray(s, startPos)
    local array = {}
    local stringLen = string.len(s)
    assert(string.sub(s, startPos, startPos) == "[", "decode_scanArray called but array does not start at position " .. startPos .. " in string:\n" .. s)
    startPos = startPos + 1
    local index = 1
    repeat
      startPos = decode_scanWhitespace(s, startPos)
      assert(stringLen >= startPos, "JSON String ended unexpectedly scanning array.")
      local curChar = string.sub(s, startPos, startPos)
      if curChar == "]" then
        return array, startPos + 1
      end
      if curChar == "," then
        startPos = decode_scanWhitespace(s, startPos + 1)
      end
      assert(stringLen >= startPos, "JSON String ended unexpectedly scanning array.")
      local object
      object, startPos = json.decode(s, startPos)
      array[index] = object
      index = index + 1
    until false
  end
  
  function decode_scanComment(s, startPos)
    assert(string.sub(s, startPos, startPos + 1) == "/*", "decode_scanComment called but comment does not start at position " .. startPos)
    local endPos = string.find(s, "*/", startPos + 2)
    assert(endPos ~= nil, "Unterminated comment in string at " .. startPos)
    return endPos + 2
  end
  
  function decode_scanConstant(s, startPos)
    local consts = {
      ["true"] = true,
      ["false"] = false,
      null = nil
    }
    local constNames = {
      "true",
      "false",
      "null"
    }
    for i, k in pairs(constNames) do
      if string.sub(s, startPos, startPos + string.len(k) - 1) == k then
        return consts[k], startPos + string.len(k)
      end
    end
    assert(nil, "Failed to scan constant from string " .. s .. " at starting position " .. startPos)
  end
  
  function decode_scanNumber(s, startPos)
    local endPos = startPos + 1
    local stringLen = string.len(s)
    local acceptableChars = "+-0123456789.e"
    while string.find(acceptableChars, string.sub(s, endPos, endPos), 1, true) and endPos <= stringLen do
      endPos = endPos + 1
    end
    local numberValue = string.sub(s, startPos, endPos - 1)
    return numberValue, endPos
  end
  
  function decode_scanObject(s, startPos)
    local object = {}
    local stringLen = string.len(s)
    local key, value
    assert(string.sub(s, startPos, startPos) == "{", "decode_scanObject called but object does not start at position " .. startPos .. " in string:\n" .. s)
    startPos = startPos + 1
    repeat
      startPos = decode_scanWhitespace(s, startPos)
      assert(stringLen >= startPos, "JSON string ended unexpectedly while scanning object.")
      local curChar = string.sub(s, startPos, startPos)
      if curChar == "}" then
        return object, startPos + 1
      end
      if curChar == "," then
        startPos = decode_scanWhitespace(s, startPos + 1)
      end
      assert(stringLen >= startPos, "JSON string ended unexpectedly scanning object.")
      key, startPos = json.decode(s, startPos)
      assert(stringLen >= startPos, "JSON string ended unexpectedly searching for value of key " .. key)
      startPos = decode_scanWhitespace(s, startPos)
      assert(stringLen >= startPos, "JSON string ended unexpectedly searching for value of key " .. key)
      assert(string.sub(s, startPos, startPos) == ":", "JSON object key-value assignment mal-formed at " .. startPos)
      startPos = decode_scanWhitespace(s, startPos + 1)
      assert(stringLen >= startPos, "JSON string ended unexpectedly searching for value of key " .. key)
      value, startPos = json.decode(s, startPos)
      object[key] = value
    until false
  end
  
  local escapeSequences = {
    ["\\t"] = "\t",
    ["\\f"] = "\f",
    ["\\r"] = "\r",
    ["\\n"] = "\n",
    ["\\b"] = "\b"
  }
  setmetatable(escapeSequences, {
    __index = function(t, k)
      return string.sub(k, 2)
    end
  })
  
  function decode_scanString(s, startPos)
    assert(startPos, "decode_scanString(..) called without start position")
    local startChar = string.sub(s, startPos, startPos)
    assert(startChar == "\"" or startChar == "'", "decode_scanString called for a non-string")
    local t = {}
    local i, j = startPos, startPos
    while string.find(s, startChar, j + 1) ~= j + 1 do
      local oldj = j
      i, j = string.find(s, "\\.", j + 1)
      local x, y = string.find(s, startChar, oldj + 1)
      if not i or i > x then
        i, j = x, y - 1
      end
      table.insert(t, string.sub(s, oldj + 1, i - 1))
      if string.sub(s, i, j) == "\\u" then
        local a = string.sub(s, j + 1, j + 4)
        j = j + 4
        local n = tonumber(a, 16)
        assert(n, "String decoding failed: bad Unicode escape " .. a .. " at position " .. i .. " : " .. j)
        local x
        if n < 128 then
          x = string.char(n % 128)
        elseif n < 2048 then
          x = string.char(192 + math.floor(n / 64) % 32, 128 + n % 64)
        else
          x = string.char(224 + math.floor(n / 4096) % 16, 128 + math.floor(n / 64) % 64, 128 + n % 64)
        end
        table.insert(t, x)
      else
        table.insert(t, escapeSequences[string.sub(s, i, j)])
      end
    end
    table.insert(t, string.sub(j, j + 1))
    assert(string.find(s, startChar, j + 1), "String decoding failed: missing closing " .. startChar .. " at position " .. j .. "(for string at position " .. startPos .. ")")
    return table.concat(t, ""), j + 2
  end
  
  function decode_scanWhitespace(s, startPos)
    local whitespace = " \n\r\t"
    local stringLen = string.len(s)
    while string.find(whitespace, string.sub(s, startPos, startPos), 1, true) and startPos <= stringLen do
      startPos = startPos + 1
    end
    return startPos
  end
  
  local escapeList = {
    ["\""] = "\\\"",
    ["\\"] = "\\\\",
    ["/"] = "\\/",
    ["\b"] = "\\b",
    ["\f"] = "\\f",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t"
  }
  
  function json_private.encodeString(s)
    local s = tostring(s)
    return s:gsub(".", function(c)
      return escapeList[c]
    end)
  end
  
  function isArray(t)
    if t == json.EMPTY_ARRAY then
      return true, 0
    end
    if t == json.EMPTY_OBJECT then
      return false
    end
    local maxIndex = 0
    for k, v in pairs(t) do
      if type(k) == "number" and math.floor(k) == k and 1 <= k then
        if not isEncodable(v) then
          return false
        end
        maxIndex = math.max(maxIndex, k)
      elseif k == "n" then
        if v ~= (t.n or #t) then
          return false
        end
      elseif isEncodable(v) then
        return false
      end
    end
    return true, maxIndex
  end
  
  function isEncodable(o)
    local t = type(o)
    return t == "string" or t == "boolean" or t == "number" or t == "nil" or t == "table" or t == "function" and o == json.null
  end
  
  return json
end

local base64CharTable = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

function tools.base64encode(data)
  return (data:gsub(".", function(x)
    local r, b = "", x:byte()
    for i = 8, 1, -1 do
      r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return r
  end) .. "0000"):gsub("%d%d%d?%d?%d?%d?", function(x)
    if #x < 6 then
      return ""
    end
    local c = 0
    for i = 1, 6 do
      c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
    end
    return base64CharTable:sub(c + 1, c + 1)
  end) .. ({
    "",
    "==",
    "="
  })[#data % 3 + 1]
end

function tools.base64decode(data)
  data = string.gsub(data, "[^" .. base64CharTable .. "=]", "")
  return (data:gsub(".", function(x)
    if x == "=" then
      return ""
    end
    local r, f = "", base64CharTable:find(x) - 1
    for i = 6, 1, -1 do
      r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
    end
    return r
  end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
    if #x ~= 8 then
      return ""
    end
    local c = 0
    for i = 1, 8 do
      c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
    end
    return string.char(c)
  end))
end

json = tools.createJson()
this.printToConsole("load LuaPanda success", 1)
return this
