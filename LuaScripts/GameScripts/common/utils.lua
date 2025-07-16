local format = string.format
local compat = require("common/compat")
local stdout = io.stdout
local append = table.insert
local concat = table.concat
local _unpack = table.unpack
local find = string.find
local sub = string.sub
local next = _ENV.next
local __math_modf = math.modf
local __math_floor = math.floor
local __math_max = math.max
local Mathf = CS.UnityEngine.Mathf
local is_windows = compat.is_windows
local err_mode = "default"
local raise, operators
local _function_factories = {}
local ReferenceEquals = CS.System.Object.ReferenceEquals
local utils = {_VERSION = "1.12.0"}
for k, v in pairs(compat) do
  utils[k] = v
end
utils.patterns = {
  FLOAT = "[%+%-%d]%d*%.?%d*[eE]?[%+%-]?%d*",
  INTEGER = "[+%-%d]%d*",
  IDEN = "[%a_][%w_]*",
  FILE = "[%a%.\\][:%][%w%._%-\\]*"
}
utils.stdmt = {
  List = {_name = "List"},
  Map = {_name = "Map"},
  Set = {_name = "Set"},
  MultiMap = {_name = "MultiMap"}
}
utils.pack = table.pack

function utils.unpack(t, i, j)
  return _unpack(t, i or 1, j or t.n or #t)
end

function utils.printf(fmt, ...)
  utils.assert_string(1, fmt)
  utils.fprintf(stdout, fmt, ...)
end

function utils.fprintf(f, fmt, ...)
  utils.assert_string(2, fmt)
  f:write(format(fmt, ...))
end

do
  local function import_symbol(T, k, v, libname)
    local key = rawget(T, k)
    
    if key and k ~= "_M" and k ~= "_NAME" and k ~= "_PACKAGE" and k ~= "_VERSION" then
      utils.fprintf(io.stderr, "warning: '%s.%s' will not override existing symbol\n", libname, k)
      return
    end
    rawset(T, k, v)
  end
  
  local function lookup_lib(T, t)
    for k, v in pairs(T) do
      if v == t then
        return k
      end
    end
    return "?"
  end
  
  local already_imported = {}
  
  function utils.import(t, T)
    T = T or _G
    t = t or utils
    if type(t) == "string" then
      t = require(t)
    end
    local libname = lookup_lib(T, t)
    if already_imported[t] then
      return
    end
    already_imported[t] = libname
    for k, v in pairs(t) do
      import_symbol(T, k, v, libname)
    end
  end
end

function utils.choose(cond, value1, value2)
  return cond and value1 or value2
end

function utils.array_tostring(t, temp, tostr)
  temp, tostr = temp or {}, tostr or tostring
  for i = 1, #t do
    temp[i] = tostr(t[i], i)
  end
  return temp
end

function utils.is_type(obj, tp)
  if type(tp) == "string" then
    return type(obj) == tp
  end
  local mt = getmetatable(obj)
  return tp == mt
end

function utils.npairs(t, i_start, i_end, step)
  step = step or 1
  if step == 0 then
    error("iterator step-size cannot be 0", 2)
  end
  local i = (i_start or 1) - step
  i_end = i_end or t.n or #t
  if step < 0 then
    return function()
      i = i + step
      if i < i_end then
        return nil
      end
      return i, t[i]
    end
  else
    return function()
      i = i + step
      if i > i_end then
        return nil
      end
      return i, t[i]
    end
  end
end

function utils.kpairs(t)
  local index
  return function()
    local value
    while true do
      index, value = next(t, index)
      if type(index) ~= "number" or __math_floor(index) ~= index then
        break
      end
    end
    return index, value
  end
end

function utils.assert_arg(n, val, tp, verify, msg, lev)
  if type(val) ~= tp then
    error(("argument %d expected a '%s', got a '%s'"):format(n, tp, type(val)), lev or 2)
  end
  if verify and not verify(val) then
    error(("argument %d: '%s' %s"):format(n, val, msg), lev or 2)
  end
  return val
end

function utils.enum(...)
  local first = select(1, ...)
  local enum = {}
  local lst
  if type(first) ~= "table" then
    lst = utils.pack(...)
    for i, value in utils.npairs(lst) do
      utils.assert_arg(i, value, "string")
      enum[value] = value
    end
  else
    utils.assert_arg(1, first, "table")
    lst = {}
    for i, value in ipairs(first) do
      if type(value) ~= "string" then
        error(("expected 'string' but got '%s' at index %d"):format(type(value), i), 2)
      end
      lst[i] = value
      enum[value] = value
    end
    for key, value in utils.kpairs(first) do
      if type(key) ~= "string" then
        error(("expected key to be 'string' but got '%s'"):format(type(key)), 2)
      end
      if enum[key] then
        error(("duplicate entry in array and hash part: '%s'"):format(key), 2)
      end
      enum[key] = value
      lst[#lst + 1] = key
    end
  end
  if not lst[1] then
    error("expected at least 1 entry", 2)
  end
  local valid = "(expected one of: '" .. concat(lst, "', '") .. "')"
  setmetatable(enum, {
    __index = function(self, key)
      error(("'%s' is not a valid value %s"):format(tostring(key), valid), 2)
    end,
    __newindex = function(self, key, value)
      error("the Enum object is read-only", 2)
    end,
    __call = function(self, key)
      if type(key) == "string" then
        local v = rawget(self, key)
        if v ~= nil then
          return v
        end
      end
      return nil, ("'%s' is not a valid value %s"):format(tostring(key), valid)
    end
  })
  return enum
end

function utils.function_arg(idx, f, msg)
  utils.assert_arg(1, idx, "number")
  local tp = type(f)
  if tp == "function" then
    return f
  end
  if tp == "string" then
    if not operators then
      operators = require("common/operator").optable
    end
    local fn = operators[f]
    if fn then
      return fn
    end
    local fn, err = utils.string_lambda(f)
    if not fn then
      error(err .. ": " .. f)
    end
    return fn
  elseif tp == "table" or tp == "userdata" then
    local mt = getmetatable(f)
    if not mt then
      error("not a callable object", 2)
    end
    local ff = _function_factories[mt]
    if not ff then
      if not mt.__call then
        error("not a callable object", 2)
      end
      return f
    else
      return ff(f)
    end
  end
  msg = msg or " must be callable"
  if 0 < idx then
    error("argument " .. idx .. ": " .. msg, 2)
  else
    error(msg, 2)
  end
end

function utils.assert_string(n, val)
  return utils.assert_arg(n, val, "string", nil, nil, 3)
end

function utils.on_error(mode)
  mode = tostring(mode)
  if ({
    default = 1,
    quit = 2,
    error = 3
  })[mode] then
    err_mode = mode
  else
    local err = "Bad argument expected string; 'default', 'quit', or 'error'. Got '" .. tostring(mode) .. "'"
    if err_mode == "default" then
      error(err, 2)
    end
    raise(err)
  end
end

function utils.raise(err)
  if err_mode == "default" then
    return nil, err
  elseif err_mode == "quit" then
    return utils.quit(err)
  else
    error(err, 2)
  end
end

raise = utils.raise

function utils.readfile(filename, is_bin)
  local mode = is_bin and "b" or ""
  utils.assert_string(1, filename)
  local f, open_err = io.open(filename, "r" .. mode)
  if not f then
    return raise(open_err)
  end
  local res, read_err = f:read("*a")
  f:close()
  if not res then
    return raise(filename .. ": " .. read_err)
  end
  return res
end

function utils.writefile(filename, str, is_bin)
  local mode = is_bin and "b" or ""
  utils.assert_string(1, filename)
  utils.assert_string(2, str)
  local f, err = io.open(filename, "w" .. mode)
  if not f then
    return raise(err)
  end
  local ok, write_err = f:write(str)
  f:close()
  if not ok then
    return raise(filename .. ": " .. write_err)
  end
  return true
end

function utils.readlines(filename)
  utils.assert_string(1, filename)
  local f, err = io.open(filename, "r")
  if not f then
    return raise(err)
  end
  local res = {}
  for line in f:lines() do
    append(res, line)
  end
  f:close()
  return res
end

function utils.executeex(cmd, bin)
  local outfile = os.tmpname()
  local errfile = os.tmpname()
  if is_windows and not outfile:find(":") then
    outfile = os.getenv("TEMP") .. outfile
    errfile = os.getenv("TEMP") .. errfile
  end
  cmd = cmd .. " > " .. utils.quote_arg(outfile) .. " 2> " .. utils.quote_arg(errfile)
  local success, retcode = utils.execute(cmd)
  local outcontent = utils.readfile(outfile, bin)
  local errcontent = utils.readfile(errfile, bin)
  os.remove(outfile)
  os.remove(errfile)
  return success, retcode, outcontent or "", errcontent or ""
end

function utils.quote_arg(argument)
  if type(argument) == "table" then
    local r = {}
    for i, arg in ipairs(argument) do
      r[i] = utils.quote_arg(arg)
    end
    return concat(r, " ")
  end
  if is_windows then
    if argument == "" or argument:find("[ \f\t\v]") then
      argument = "\"" .. argument:gsub("(\\*)\"", "%1%1\\\""):gsub("\\+$", "%0%0") .. "\""
    end
    return (argument:gsub("[\"^<>!|&%%]", "^%0"))
  else
    if argument == "" or argument:find("[^a-zA-Z0-9_@%+=:,./-]") then
      argument = "'" .. argument:gsub("'", "'\\''") .. "'"
    end
    return argument
  end
end

function utils.quit(code, msg, ...)
  if type(code) == "string" then
    utils.fprintf(io.stderr, code, msg, ...)
    io.stderr:write("\n")
    code = -1
  elseif msg then
    utils.fprintf(io.stderr, msg, ...)
    io.stderr:write("\n")
  end
  os.exit(code, true)
end

function utils.escape(s)
  utils.assert_string(1, s)
  return (s:gsub("[%-%.%+%[%]%(%)%$%^%%%?%*]", "%%%1"))
end

function utils.split(s, re, plain, n)
  utils.assert_string(1, s)
  local i1, ls = 1, {}
  re = re or "%s+"
  if re == "" then
    return {s}
  end
  while true do
    local i2, i3 = find(s, re, i1, plain)
    if not i2 then
      local last = sub(s, i1)
      if last ~= "" then
        append(ls, last)
      end
      if #ls == 1 and ls[1] == "" then
        return {}
      else
        return ls
      end
    end
    append(ls, sub(s, i1, i2 - 1))
    if n and #ls == n then
      ls[#ls] = sub(s, i1)
      return ls
    end
    i1 = i3 + 1
  end
end

function utils.splitv(s, re, plain, n)
  return _unpack(utils.split(s, re, plain, n))
end

function utils.memoize(func)
  local cache = {}
  return function(k)
    local res = cache[k]
    if res == nil then
      res = func(k)
      cache[k] = res
    end
    return res
  end
end

function utils.add_function_factory(mt, fun)
  _function_factories[mt] = fun
end

local function _string_lambda(f)
  if f:find("^|") or f:find("_") then
    local args, body = f:match("|([^|]*)|(.+)")
    if f:find("_") then
      args = "_"
      body = f
    elseif not args then
      return raise("bad string lambda")
    end
    local fstr = "return function(" .. args .. ") return " .. body .. " end"
    local fn, err = utils.load(fstr)
    if not fn then
      return raise(err)
    end
    fn = fn()
    return fn
  else
    return raise("not a string lambda")
  end
end

utils.string_lambda = utils.memoize(_string_lambda)

function utils.bind1(fn, p)
  fn = utils.function_arg(1, fn)
  return function(...)
    return fn(p, ...)
  end
end

function utils.bind2(fn, p)
  fn = utils.function_arg(1, fn)
  return function(x, ...)
    return fn(x, p, ...)
  end
end

do
  local function deprecation_func(msg, trace)
    if trace then
      warn(msg, "\n", trace)
    else
      warn(msg)
    end
  end
  
  function utils.set_deprecation_func(func)
    if func == nil then
      function deprecation_func()
      end
    else
      utils.assert_arg(1, func, "function")
      deprecation_func = func
    end
  end
  
  function utils.raise_deprecation(opts)
    utils.assert_arg(1, opts, "table")
    if type(opts.message) ~= "string" then
      error("field 'message' of the options table must be a string", 2)
    end
    local trace
    if not opts.no_trace then
      trace = debug.traceback("", 2):match([[
[
%s]*(.-)$]])
    end
    local msg
    if opts.deprecated_after and opts.version_removed then
      msg = (" (deprecated after %s, scheduled for removal in %s)"):format(tostring(opts.deprecated_after), tostring(opts.version_removed))
    elseif opts.deprecated_after then
      msg = (" (deprecated after %s)"):format(tostring(opts.deprecated_after))
    elseif opts.version_removed then
      msg = (" (scheduled for removal in %s)"):format(tostring(opts.version_removed))
    else
      msg = ""
    end
    msg = opts.message .. msg
    if opts.source then
      msg = "[" .. opts.source .. "] " .. msg
    elseif msg:sub(1, 1) == "@" then
      error("message cannot start with '@'", 2)
    end
    deprecation_func(msg, trace)
  end
end

function utils.changeCSArrayToLuaTable(configData)
  if not configData then
    return
  end
  if type(configData) ~= "userdata" then
    log.error("changeCSArrayToLuaTable  error configData ~= userdata  type == " .. type(configData))
    return
  end
  local dataTab = {}
  for i = 0, configData.Length - 1 do
    local data = {}
    local item = configData[i]
    if type(item) == "userdata" then
      for j = 0, item.Length - 1 do
        data[#data + 1] = item[j]
      end
    else
      data = item
    end
    dataTab[#dataTab + 1] = data
  end
  return dataTab
end

function utils.changeStringRewardToLuaTable(rewardStr)
  if not rewardStr then
    return
  end
  if type(rewardStr) ~= "string" then
    log.error("changeStringRewardToLuaTable  error rewardStr ~= string  type == " .. type(rewardStr))
    return
  end
  local dataTab = {}
  local rewardTab = string.split(rewardStr, ";")
  if rewardTab then
    for i = 1, #rewardTab do
      local reward = string.split(rewardTab[i], ",")
      local tab = {}
      for m, n in ipairs(reward) do
        tab[m] = tonumber(n)
      end
      dataTab[#dataTab + 1] = tab
    end
  end
  return dataTab
end

function utils.stringToTimeStamp(server_time_str)
  local date_pattern = "(%d+)-(%d+)-(%d+)%s*(%d+):(%d+):(%d+)"
  local start_time = server_time_str or "1971-01-01 1:00:00"
  local _, _, _y, _m, _d, _hour, _min, _sec = string.find(start_time, date_pattern)
  local timestamp = os.time({
    year = _y,
    month = _m,
    day = _d,
    hour = _hour,
    min = _min,
    sec = _sec
  })
  local server_time_zone = TimeUtil:GetServerTimeGmtOff()
  local local_time_zone = TimeUtil:getLocalTimeZone()
  return timestamp + local_time_zone - server_time_zone
end

function utils.getTimeLayoutBySecond(second)
  local n = __math_max(0, second)
  local day = __math_modf(n / 86400)
  n = n % 86400
  local hour = __math_modf(n / 3600)
  n = n % 3600
  local min = __math_modf(n / 60)
  local sec = __math_floor(n % 60 + 0.5)
  return day, hour, min, sec
end

function utils.openItemDetailPop(itemData, callBackFun, inBag)
  local id = itemData.iID and itemData.iID or itemData.iBaseId
  if id == MTTDProto.SpecialItem_ShowDiamond then
    StackPopup:Push(UIDefines.ID_FORM_DIAMOND, {
      iID = itemData.iID
    })
    return
  end
  local itemType = ResourceUtil:GetResourceTypeById(id)
  if itemType == ResourceUtil.RESOURCE_TYPE.EQUIPS then
    StackPopup:Push(UIDefines.ID_FORM_ITEMTIPS, {
      equipData = itemData,
      bBag = inBag,
      callBackFun = callBackFun
    })
  elseif itemType == ResourceUtil.RESOURCE_TYPE.BackGround then
    StackPopup:Push(UIDefines.ID_FORM_HALLBGPOPUP, {bgId = id})
  elseif itemType == ResourceUtil.RESOURCE_TYPE.LEGACY then
    StackPopup:Push(UIDefines.ID_FORM_HEROLEGACYITEMTIPS, {legacyID = id, callBackFun = callBackFun})
  elseif itemType == ResourceUtil.RESOURCE_TYPE.HEROES then
    StackPopup:Push(UIDefines.ID_FORM_HEROCHECK, {
      heroID = itemData.iID,
      heroServerData = itemData.heroServerData,
      callBackFun = callBackFun
    })
  else
    StackPopup:Push(UIDefines.ID_FORM_ITEMTIPS, {
      iID = itemData.iID,
      iNum = itemData.iNum,
      bBag = inBag,
      callBackFun = callBackFun,
      forceSetNum = itemData.forceSetNum
    })
  end
end

local cur_prompt_tips
utils.PromptTipsStyle = {PromptTips = 1, RewardTips = 2}

function utils.createPromptTips(paramData)
  local prefabPath = "ui_common_prompt_tips"
  local luaPath = "UI/Common/UIPromptTips"
  local parentObj
  if not CS.UI.UILuaHelper.CheckFormUIIsShow(UIDefines.ID_FORM_COMMONRECEIVE) then
    StackTop:Push(UIDefines.ID_FORM_COMMONRECEIVE, paramData)
    return
  end
  local commonReceive = StackTop:GetUIInstanceLua(UIDefines.ID_FORM_COMMONRECEIVE)
  if commonReceive and commonReceive.m_csui and commonReceive:IsActive() then
    local m_rootTrans = commonReceive.m_csui.m_uiGameObject.transform
    parentObj = m_rootTrans:Find("m_content/m_tips_parent_node").gameObject
    commonReceive:DelayCloseCommonTipsRootUI(paramData)
  else
    log.error("utils.createPromptTips ID_FORM_COMMONRECEIVE can not opened")
  end
  
  local function loadBack(bindLua)
    cur_prompt_tips = bindLua
  end
  
  ResourceUtil:LoadPrefabAndBindLua(prefabPath, luaPath, parentObj, paramData, loadBack)
end

function utils.resetLookInfoTips()
  cur_prompt_tips = nil
end

function utils.destroyLookInfoTips()
  if cur_prompt_tips then
    cur_prompt_tips:OnDestroy()
  end
end

function utils.popUpRewardUI(vReward, closeCallBack, mChangeReward)
  local vItemReward = {}
  if not vReward then
    return
  end
  if mChangeReward then
    if mChangeReward and type(mChangeReward) == "table" and next(mChangeReward) then
      for i, v in ipairs(vReward) do
        local curId = v.iID
        local num = v.iNum
        local data = {
          iID = curId,
          iNum = num,
          isRepeat = false
        }
        local length = 0
        if mChangeReward[curId] then
          length = #mChangeReward[curId]
          if length ~= data.iNum then
            data.isRepeat = false
            vItemReward[#vItemReward + 1] = data
          end
        else
          vItemReward[#vItemReward + 1] = data
        end
        local subTurnData = mChangeReward[curId]
        for i = 1, length do
          local subData = {
            iID = v.iID,
            iNum = 1,
            isRepeat = true,
            isTrunId = subTurnData[i].iID,
            isTrunNum = subTurnData[i].iNum
          }
          vItemReward[#vItemReward + 1] = subData
        end
      end
    else
      vItemReward = vReward
    end
  else
    vItemReward = vReward
  end
  local tempShowDisPlayNewPlayer = {}
  local vHeroID = {}
  tempShowDisPlayNewPlayer = vItemReward
  for i, v in ipairs(tempShowDisPlayNewPlayer) do
    if ResourceUtil:GetResourceTypeById(v.iID) == ResourceUtil.RESOURCE_TYPE.HEROES then
      vHeroID[#vHeroID + 1] = v.iID
    end
  end
  if 0 < #vHeroID then
    PushFaceManager:OnNewHero({vHeroID = vHeroID})
  end
  PushFaceManager:OnGetCommonReward({vItem = vItemReward, closeCallBack = closeCallBack})
end

local DirectionsUIStyle = {
  OneBtn = 1,
  TwoBtn = 2,
  AutoOneBtn = 3,
  PopBig = 4,
  PopMiddle = 5,
  PopSmall = 6
}
local mCommonTipsCache = {}

function utils.CheckAndPushCommonTips(tipsParams)
  local uiInfo = StackTop:GetUIInstanceLua(UIDefines.ID_FORM_COMMONTIPS)
  if uiInfo and uiInfo.m_csui and uiInfo:IsActive() then
    table.insert(mCommonTipsCache, tipsParams)
  else
    if 0 < #mCommonTipsCache then
      tipsParams = mCommonTipsCache[1]
      table.remove(mCommonTipsCache, 1)
    end
    if tipsParams then
      StackTop:Push(UIDefines.ID_FORM_COMMONTIPS, tipsParams)
    end
  end
end

function utils.popUpDirectionsUI(tipsParams)
  if not tipsParams then
    return
  end
  if not tipsParams.tipsID then
    utils.CheckAndPushCommonTips(tipsParams)
    return
  end
  local ConfirmCommonTipsIns = ConfigManager:GetConfigInsByName("ConfirmCommonTips")
  local commonTextCfg = ConfirmCommonTipsIns:GetValue_ByID(tipsParams.tipsID)
  if not commonTextCfg:GetError() then
    if commonTextCfg.m_style == DirectionsUIStyle.PopBig then
      StackTop:Push(UIDefines.ID_FORM_DIRECTIONS_BIG, tipsParams)
    elseif commonTextCfg.m_style == DirectionsUIStyle.PopMiddle then
      StackTop:Push(UIDefines.ID_FORM_DIRECTIONS_MIDDLE, tipsParams)
    elseif commonTextCfg.m_style == DirectionsUIStyle.PopSmall then
      StackTop:Push(UIDefines.ID_FORM_DIRECTIONS_SMALL, tipsParams)
    else
      utils.CheckAndPushCommonTips(tipsParams)
    end
  end
end

function utils.getScreenSafeArea()
  if not ScreenSafeArea then
    return
  end
  local posX = ScreenSafeArea.x
  local posY = ScreenSafeArea.y
  local width = ScreenSafeArea.width
  local height = ScreenSafeArea.height
  return width, height, posX, posY
end

function utils.getScreenSafeAreaRatio()
  if not ScreenSafeArea then
    return
  end
  return ScreenSafeArea.width / ScreenSafeArea.height
end

local __SCREEN_WIDTH = 1920
local __SCREEN_HEIGHT = 1080

function utils.setScreenSize(width, height)
  if not width or not height then
    return
  end
  __SCREEN_WIDTH = width
  __SCREEN_HEIGHT = height
end

function utils.getScreenSafeAreaRealSize()
  local screenWidth = CS.UnityEngine.Screen.width
  local width, height, posX, posY = utils.getScreenSafeArea()
  local anchorMinX = posX / screenWidth
  local anchorMaxX = (posX + width) / screenWidth
  local realWidth = __SCREEN_WIDTH * (anchorMaxX - anchorMinX)
  local realHeight = __SCREEN_HEIGHT
  return {width = realWidth, height = realHeight}
end

function utils.openSkillTips(skill_id, skill_group_id, hero_cfg_id, click_transform, content_pivot, pos_offset, skill_lv)
  local params = {
    skill_id = skill_id,
    skill_group_id = skill_group_id,
    hero_cfg_id = hero_cfg_id,
    click_transform = click_transform,
    content_pivot = content_pivot,
    pos_offset = pos_offset,
    skill_lv = skill_lv
  }
  StackPopup:Push(UIDefines.ID_FORM_POPOVERSKILL, params)
end

function utils.ShowDialogueGame(dialogId, finishFc)
  local params = {dialogId = dialogId, finishFc = finishFc}
  StackPopup:Push(UIDefines.ID_FORM_INTERACTIVEGAME, params)
end

function utils.openForm_filter(filterData, click_transform, content_pivot, pos_offset, chooseBackFun, isHideShowMoonType, isInBattle, isHideCamp)
  local params = {
    filterData = filterData,
    isHideShowMoonType = isHideShowMoonType,
    click_transform = click_transform,
    content_pivot = content_pivot,
    pos_offset = pos_offset,
    chooseBackFun = chooseBackFun,
    isInBattle = isInBattle,
    isHideCamp = isHideCamp
  }
  StackPopup:Push(UIDefines.ID_FORM_FILTER, params)
end

function utils.openLegacySkillTips(legacyID, legacyLv, skillID, clickTrans, contentPivot, posOffset)
  local params = {
    legacyID = legacyID,
    legacyLv = legacyLv,
    skillID = skillID,
    clickTrans = clickTrans,
    contentPivot = contentPivot,
    posOffset = posOffset
  }
  StackPopup:Push(UIDefines.ID_FORM_HEROLEGACYTIPS, params)
end

function utils.ShowPrefabHelper(prefabhelper, callback, data, params)
  if not prefabhelper or not data then
    return
  end
  
  local function func(go, index)
    if callback then
      callback(go, index, data[index + 1], params)
    end
  end
  
  prefabhelper:RegisterCallback(func)
  prefabhelper:CheckAndCreateObjs(#data)
end

function utils.AdaptCamera(camera)
  local adaptHeight
  local ratio = 1.7777777777777777
  local screenRatio = CS.UnityEngine.Screen.width / CS.UnityEngine.Screen.height
  if ratio > screenRatio then
    adaptHeight = Mathf.RoundToInt(1920 / CS.UnityEngine.Screen.width * CS.UnityEngine.Screen.height)
    local curRatio = adaptHeight / 1080
    camera.fieldOfView = camera.fieldOfView * curRatio
  end
end

function utils.openRogueItemTips(item_id, includeHeroIdList, isHaveItemIds)
  local params = {
    item_id = item_id,
    includeHeroIdList = includeHeroIdList,
    isHaveItemIds = isHaveItemIds
  }
  StackPopup:Push(UIDefines.ID_FORM_ROGUEITEMTIPS, params)
end

function utils.ShowCommonTipCost(showParam)
  if not showParam.afterItemID then
    StackPopup:Push(UIDefines.ID_FORM_COMMONTIPCOSTONE, showParam)
  else
    StackPopup:Push(UIDefines.ID_FORM_COMMONTIPCOST, showParam)
  end
end

function utils.removeLoginDoor()
  if __LoginSceneRoot then
    GameObject.Destroy(__LoginSceneRoot)
    __LoginSceneRoot = nil
  end
end

function utils.isNull(uObj)
  return uObj == nil or ReferenceEquals(uObj, nil) or type(uObj) == "userdata" and uObj:Equals(nil)
end

local HyperCMD = {}

function HyperCMD.Tips_ID(params)
  StackTop:Push(UIDefines.ID_FORM_SKILLSPEDESCTIPS, params[2])
end

function HyperCMD.WebView_Url(params)
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS, params[2])
end

function utils.OnHyperLinkClicked(hyper_str)
  local params = string.split(hyper_str, ";")
  local f = HyperCMD[params[1]]
  if f then
    return f(params)
  end
  log.error("OnHyperLinkClicked is error! The Method does not exist!----", params[1])
end

function utils.generateUniqueRandomXNumOfRange(min, max, count)
  if type(min) ~= "number" or type(max) ~= "number" then
    return nil
  end
  if max <= min or count > max - min + 1 then
    return nil
  end
  local result = {}
  local chosen = {}
  math.newrandomseed()
  while count > #result do
    local num = math.random(min, max)
    if not chosen[num] then
      chosen[num] = true
      table.insert(result, num)
    end
  end
  
  local function sortFun(data1, data2)
    return data1 < data2
  end
  
  table.sort(result, sortFun)
  return result
end

function utils.addRollingTips(tipsParamsList)
  local tipsTab = {}
  local maxNum = 0
  for i, tipsParams in ipairs(tipsParamsList) do
    tipsTab[i] = {}
    for m = 1, tipsParams.iDisplayNum do
      table.insert(tipsTab[i], tipsParams)
    end
    if maxNum < tipsParams.iDisplayNum then
      maxNum = tipsParams.iDisplayNum
    end
  end
  local tipsList = {}
  for m = 1, maxNum do
    for n = 1, table.getn(tipsTab) do
      if tipsTab[n][m] then
        tipsList[#tipsList + 1] = tipsTab[n][m]
      end
    end
  end
  if not CS.UI.UILuaHelper.CheckFormUIIsShow(UIDefines.ID_FORM_ROLLING_TIPS) then
    StackSpecial:Push(UIDefines.ID_FORM_ROLLING_TIPS, tipsList)
    return
  end
  local luaIns = StackSpecial:GetUIInstanceLua(UIDefines.ID_FORM_ROLLING_TIPS)
  if luaIns and luaIns.m_csui and luaIns:IsActive() then
    for i, tipsParams in ipairs(tipsList) do
      luaIns:AddTips(tipsParams)
    end
  else
    log.error("utils.createRollingTips ID_FORM_ROLLING_TIPS can not opened")
  end
end

function utils.TryLoadUIPrefabInParent(parentNodeTrans, prefabStr, backFun)
  local childCount = parentNodeTrans.childCount
  if 0 < childCount then
    for i = childCount, 1, -1 do
      local tempChildTrans = parentNodeTrans:GetChild(i - 1)
      if tempChildTrans and not UILuaHelper.IsNull(tempChildTrans) then
        local childPrefabStr = tempChildTrans.name
        UIDynamicObjectManager:RecycleObjectByName(childPrefabStr, tempChildTrans)
      end
    end
  end
  UIDynamicObjectManager:GetObjectByName(prefabStr, function(nameStr, object)
    if UILuaHelper.IsNull(parentNodeTrans) then
      UIDynamicObjectManager:RecycleObjectByName(prefabStr, object)
      return
    end
    UILuaHelper.SetActive(object, true)
    UILuaHelper.SetParent(object, parentNodeTrans, true)
    object.name = nameStr
    if backFun then
      backFun(nameStr, object)
    end
  end)
end

function utils.RecycleInParentUIPrefab(prefabStr, prefabObj)
  if not prefabStr then
    return
  end
  if not prefabObj then
    return
  end
  UIDynamicObjectManager:RecycleObjectByName(prefabStr, prefabObj)
end

return utils
