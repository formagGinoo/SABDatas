function checknumber(value, base)
  return tonumber(value, base) or 0
end

local Mathf = CS.UnityEngine.Mathf

function checkint(value)
  return math.round(checknumber(value))
end

function getLegalStr(srcString)
  local contentStr = srcString or ""
  contentStr = string.gsub(contentStr, "%[", "(")
  contentStr = string.gsub(contentStr, "%]", ")")
  contentStr = string.gsub(contentStr, "\n", "")
  contentStr = string.gsub(contentStr, "\t", "")
  contentStr = string.gsub(contentStr, "\r", "")
  contentStr = string.gsub(contentStr, "%%", "")
  contentStr = string.trim(contentStr)
  return contentStr
end

function checkbool(value)
  return value ~= nil and value ~= false
end

function checktable(value)
  if type(value) ~= "table" then
    value = {}
  end
  return value
end

function isset(hashtable, key)
  local t = type(hashtable)
  return (t == "table" or t == "userdata") and hashtable[key] ~= nil
end

function clone(object)
  local lookup_table = {}
  
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for key, value in pairs(object) do
      new_table[_copy(key)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  
  return _copy(object)
end

function iskindof(obj, classname)
  local t = type(obj)
  local mt
  if t == "table" then
    mt = getmetatable(obj)
  elseif t == "userdata" then
    mt = tolua.getpeer(obj)
  end
  while mt do
    if mt.__cname == classname then
      return true
    end
    mt = mt.super
  end
  return false
end

function import(moduleName, currentModuleName)
  local currentModuleNameParts
  local moduleFullName = moduleName
  local offset = 1
  while true do
    if string.byte(moduleName, offset) ~= 46 then
      moduleFullName = string.sub(moduleName, offset)
      if currentModuleNameParts and 0 < #currentModuleNameParts then
        moduleFullName = table.concat(currentModuleNameParts, ".") .. "." .. moduleFullName
      end
      break
    end
    offset = offset + 1
    if not currentModuleNameParts then
      if not currentModuleName then
        local n, v = debug.getlocal(3, 1)
        currentModuleName = v
      end
      currentModuleNameParts = string.split(currentModuleName, ".")
    end
    table.remove(currentModuleNameParts, #currentModuleNameParts)
  end
  return require(moduleFullName)
end

function reloadRequire(m)
  local md5File = getLuaPath(m)
  local luaFile = g_requireList[md5File]
  if luaFile ~= nil then
    log.debug("reloadRequire:" .. luaFile)
    unrequire(luaFile)
    require(luaFile)
  else
    require(m)
  end
end

function isRequire(m)
  local luaFile = g_requireList[m]
  if luaFile ~= nil then
    return true
  end
  return false
end

function handler(obj, method)
  return function(...)
    if method ~= nil then
      return method(obj, ...)
    end
  end
end

function handlerParams(obj, method, ...)
  return function(...)
    if method ~= nil then
      return method(obj, ...)
    end
  end
end

function handler1(obj, method, param1)
  return function(...)
    if method ~= nil then
      return method(obj, param1, ...)
    end
  end
end

function handler2(obj, method, param1, param2)
  return function(...)
    if method ~= nil then
      return method(obj, param1, param2, ...)
    end
  end
end

function AddClickListenerWithParams(button, callback, prm1, prm2, prm3, prm4)
  local function onclick()
    callback(button, prm1, prm2, prm3, prm4)
  end
  
  if button then
    button.onClick:RemoveAllListeners()
    button.onClick:AddListener(onclick)
  end
end

function AddClickListener(button, callback, param)
  local function onclick()
    callback(button, param)
  end
  
  if button then
    button.onClick:RemoveAllListeners()
    button.onClick:AddListener(onclick)
  end
end

function AddToggleValueChangeCallback(toggle, cb, param)
  local function toggleCallback(isOn)
    cb(toggle, isOn, param)
  end
  
  if toggle then
    toggle.onValueChanged:RemoveAllListeners()
    toggle.onValueChanged:AddListener(toggleCallback)
  end
end

function math.newrandomseed()
  local ok, socket = pcall(function()
    return require("socket")
  end)
  if ok then
    math.randomseed(socket.gettime() * 1000)
  else
    math.randomseed(os.time())
  end
  math.random()
  math.random()
  math.random()
  math.random()
end

function math.commonRandom(min, max, sign)
  if math.nextSeed == nil then
    math.commonSeed(2147483647)
  end
  local result
  if min == nil and max == nil then
    result = math.commonRandomInt()
  else
    local range = max - min
    if range == 0 then
      result = min
    else
      result = min + math.commonRandomInt() % range
    end
  end
  return result
end

function math.commonRandom_1_1()
  return 2 * (math.commonRandomInt() / 2147483647) - 1
end

function math.commonRandom_0_1()
  return math.commonRandomInt() / 2147483647
end

math.commonSeedCallback = nil

function math.commonSeed(seed)
  if seed < 0 then
    seed = seed + 2147483647
  end
  math.nextSeed = seed
  if math.nextSeed == 0 then
    math.nextSeed = 1
  end
  if nil ~= math.commonSeedCallback then
    math.commonSeedCallback(seed)
  end
end

local Q = math.floor(44488.07041494893)
local R = 3399

function math.commonRandomInt()
  local tmpState = math.floor(48271 * (math.nextSeed % Q) - R * (math.nextSeed / Q))
  if 0 < tmpState then
    math.nextSeed = tmpState
  else
    math.nextSeed = tmpState + 2147483647
  end
  return math.nextSeed
end

function math.round(value)
  return math.floor(value + 0.5)
end

local FLOAT_CUT_5 = 5
local FLOAT_CUT_11 = 11
local FLOAT_CUT_14 = 14

function math.roundfloor(value, num)
  if num == nil then
    num = 0
  end
  local pow = Mathf.Pow(10, num)
  return math.floor(value * pow + 0.5) / pow
end

function math.angle2radian(angle)
  return angle * math.pi / 180
end

function math.radian2angle(radian)
  return radian / math.pi * 180
end

function table.clear(t)
  if t == nil then
    return
  end
  for k, _ in pairs(t) do
    t[k] = nil
  end
end

function table.empty(t)
  return t == nil or next(t) == nil
end

function table.getn(t)
  if t == nil then
    return 0
  end
  local count = 0
  for k, v in pairs(t) do
    count = count + 1
  end
  return count
end

function table.keys(hashtable)
  local keys = {}
  for k, v in pairs(hashtable) do
    keys[#keys + 1] = k
  end
  return keys
end

function table.values(hashtable)
  local values = {}
  for k, v in pairs(hashtable) do
    values[#values + 1] = v
  end
  return values
end

function table.merge(dest, src)
  for k, v in pairs(src) do
    dest[k] = v
  end
end

function table.insertto(dest, src, begin)
  begin = checkint(begin)
  if begin <= 0 then
    begin = #dest + 1
  end
  local len = #src
  for i = 0, len - 1 do
    dest[i + begin] = src[i + 1]
  end
end

function table.indexof(array, value, begin)
  for i = begin or 1, #array do
    if array[i] == value then
      return i
    end
  end
  return false
end

function table.keyof(hashtable, value)
  for k, v in pairs(hashtable) do
    if v == value then
      return k
    end
  end
  return nil
end

function table.Valueof(hashtable, key)
  for k, v in pairs(hashtable) do
    if k == key then
      return v
    end
  end
  return nil
end

function table.removebyvalue(array, value, removeall)
  local c, i, max = 0, 1, #array
  while i <= max do
    if array[i] == value then
      table.remove(array, i)
      c = c + 1
      i = i - 1
      max = max - 1
      if not removeall then
        break
      end
    end
    i = i + 1
  end
  return c
end

function table.map(t, fn)
  for k, v in pairs(t) do
    t[k] = fn(v, k)
  end
end

function table.walk(t, fn)
  for k, v in pairs(t) do
    fn(v, k)
  end
end

function table.filter(t, fn)
  for k, v in pairs(t) do
    if not fn(v, k) then
      t[k] = nil
    end
  end
end

function table.unique(t)
  local check = {}
  local n = {}
  for k, v in pairs(t) do
    if not check[v] then
      n[k] = v
      check[v] = true
    end
  end
  return n
end

local function isArray(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then
      return false
    end
  end
  return true
end

function table.serialize(t)
  local mark = {}
  local assign = {}
  
  local function table2str(t, parent)
    mark[t] = parent
    local ret = {}
    if isArray(t) then
      for i, v in pairs(t) do
        local k = tostring(i)
        local dotkey = parent .. "[" .. k .. "]"
        local t = type(v)
        if t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
        elseif t == "table" then
          if mark[v] then
            table.insert(assign, dotkey .. "=" .. mark[v])
          else
            table.insert(ret, table2str(v, dotkey))
          end
        elseif t == "string" then
          table.insert(ret, string.format("%q", v))
        elseif t == "number" then
          if v == math.huge then
            table.insert(ret, "math.huge")
          elseif v == -math.huge then
            table.insert(ret, "-math.huge")
          else
            table.insert(ret, tostring(v))
          end
        else
          table.insert(ret, tostring(v))
        end
      end
    else
      for f, v in pairs(t) do
        local k = type(f) == "number" and "[" .. f .. "]" or f
        if type(f) == "string" then
          k = "[\"" .. f .. "\"]"
        end
        local t = type(v)
        if v == nil or type(k) == "table" then
        elseif t == "userdata" or t == "function" or t == "thread" or t == "proto" or t == "upval" then
        elseif t == "table" then
          local dotkey = parent .. (type(f) == "number" and k or k)
          if mark[v] then
            table.insert(assign, dotkey .. "=" .. mark[v])
          else
            table.insert(ret, string.format("%s=%s", k, table2str(v, dotkey)))
          end
        elseif t == "string" then
          table.insert(ret, string.format("%s=%q", k, v))
        elseif t == "number" then
          if v == math.huge then
            table.insert(ret, string.format("%s=%s", k, "math.huge"))
          elseif v == -math.huge then
            table.insert(ret, string.format("%s=%s", k, "-math.huge"))
          else
            table.insert(ret, string.format("%s=%s", k, tostring(v)))
          end
        else
          table.insert(ret, string.format("%s=%s", k, tostring(v)))
        end
      end
    end
    return "{" .. table.concat(ret, ",") .. "}"
  end
  
  if type(t) == "table" then
    return string.format("%s%s", table2str(t, "_"), table.concat(assign, " "))
  else
    return tostring(t)
  end
end

function table.unserialize(str)
  if str == nil or str == "nil" then
    return nil
  elseif type(str) ~= "string" then
    EMPTY_TABLE = {}
    return EMPTY_TABLE
  elseif #str == 0 then
    EMPTY_TABLE = {}
    return EMPTY_TABLE
  end
  local code, ret = pcall(load(string.format("do local _=%s return _ end", str)))
  if code then
    return ret
  else
    EMPTY_TABLE = {}
    return EMPTY_TABLE
  end
end

function table.serialize_debug(t)
  if GameSettings.m_bIsDebugMode == true then
    local s = table.serialize(t) or " "
    return string.gsub(s, "%%", "*")
  else
    return ""
  end
end

function table.serialize_format(root, indent, allKeys)
  indent = indent or 0
  local result = {
    string.rep("    ", indent) .. "{"
  }
  
  local function _dump(root, indent)
    if 30 < indent then
      return
    end
    for k, v in pairs(root) do
      local type_k, type_v = type(k), type(v)
      if type_k == "string" and string.len(k) > 2 and string.sub(k, 1, 2) == "__" then
        break
      end
      if type_k == "number" or type_k == "string" or allKeys then
        local szSuffix = ""
        if type_v == "table" then
          szSuffix = "{"
        end
        local key = k
        if type_k == "number" then
          key = "[" .. tostring(k) .. "]"
        end
        local szPrefix = string.rep("    ", indent)
        local formatting = szPrefix .. tostring(key) .. " = " .. szSuffix
        if type(v) == "table" then
          table.insert(result, formatting)
          _dump(v, indent + 1)
          table.insert(result, szPrefix .. "},")
        else
          local szValue = ""
          if type(v) == "string" then
            szValue = "\"" .. v .. "\""
          else
            szValue = tostring(v)
          end
          table.insert(result, formatting .. szValue .. ",")
        end
      end
    end
  end
  
  _dump(root, indent + 1)
  table.insert(result, string.rep("    ", indent) .. "}")
  return table.concat(result, "\n")
end

string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

function remove_table_key(tbl)
  for k, v in pairs(tbl) do
    if type(k) == "table" then
      tbl[k] = nil
    elseif type(v) == "table" then
      remove_table_key(v)
    end
  end
  return tbl
end

function string.htmlspecialchars(input)
  for k, v in pairs(string._htmlspecialchars_set) do
    input = string.gsub(input, k, v)
  end
  return input
end

function string.restorehtmlspecialchars(input)
  for k, v in pairs(string._htmlspecialchars_set) do
    input = string.gsub(input, v, k)
  end
  return input
end

function string.nl2br(input)
  return string.gsub(input, "\n", "<br />")
end

function string.text2html(input)
  input = string.gsub(input, "\t", "    ")
  input = string.htmlspecialchars(input)
  input = string.gsub(input, " ", "&nbsp;")
  input = string.nl2br(input)
  return input
end

function string.split(input, delimiter)
  input = tostring(input)
  delimiter = tostring(delimiter)
  if delimiter == "" then
    return false
  end
  local pos, arr = 0, {}
  for st, sp in function()
    return string.find(input, delimiter, pos, true)
  end, nil, nil do
    table.insert(arr, string.sub(input, pos, st - 1))
    pos = sp + 1
  end
  table.insert(arr, string.sub(input, pos))
  return arr
end

function string.ltrim(input)
  return string.gsub(input, "^[ \t\n\r]+", "")
end

function string.rtrim(input)
  return string.gsub(input, "[ \t\n\r]+$", "")
end

function string.trim(input)
  input = string.gsub(input, "^[ \t\n\r]+", "")
  return string.gsub(input, "[ \t\n\r]+$", "")
end

function strtrim(str)
  if str == nil or str == "" then
    return str
  end
  local str2 = string.trim(str)
  return str2
end

function string.ucfirst(input)
  return string.upper(string.sub(input, 1, 1)) .. string.sub(input, 2)
end

local function urlencodechar(char)
  return "%" .. string.format("%02X", string.byte(char))
end

function string.urlencode(input)
  input = string.gsub(tostring(input), "\n", "\r\n")
  input = string.gsub(input, "([^%w%.%- ])", urlencodechar)
  return string.gsub(input, " ", "+")
end

function string.urldecode(input)
  input = string.gsub(input, "+", " ")
  input = string.gsub(input, "%%(%x%x)", function(h)
    return string.char(checknumber(h, 16))
  end)
  input = string.gsub(input, "\r\n", "\n")
  return input
end

function string.utf8len(input)
  local len = string.len(input)
  local left = len
  local cnt = 0
  local arr = {
    0,
    192,
    224,
    240,
    248,
    252
  }
  while left ~= 0 do
    local tmp = string.byte(input, -left)
    local i = #arr
    while arr[i] do
      if tmp >= arr[i] then
        left = left - i
        break
      end
      i = i - 1
    end
    cnt = cnt + 1
  end
  return cnt
end

function string.utf8charbytes(s, i)
  i = i or 1
  if type(s) ~= "string" then
    Mlog:error("bad argument #1 to 'utf8charbytes' (string expected, got " .. type(s) .. ")")
    return
  end
  if type(i) ~= "number" then
    Mlog:error("bad argument #2 to 'utf8charbytes' (number expected, got " .. type(i) .. ")")
    return
  end
  local c = s:byte(i)
  if 0 < c and c <= 127 then
    return 1
  elseif 194 <= c and c <= 223 then
    local c2 = s:byte(i + 1)
    if not c2 then
      Mlog:error("UTF-8 string terminated early")
      return
    end
    if c2 < 128 or 191 < c2 then
      Mlog:error("Invalid UTF-8 character")
      return
    end
    return 2
  elseif 224 <= c and c <= 239 then
    local c2 = s:byte(i + 1)
    local c3 = s:byte(i + 2)
    if not c2 or not c3 then
      Mlog:error("UTF-8 string terminated early")
      return
    end
    if c == 224 and (c2 < 160 or 191 < c2) then
      Mlog:error("Invalid UTF-8 character")
      return
    elseif c == 237 and (c2 < 128 or 159 < c2) then
      Mlog:error("Invalid UTF-8 character")
      return
    elseif c2 < 128 or 191 < c2 then
      Mlog:error("Invalid UTF-8 character")
      return
    end
    if c3 < 128 or 191 < c3 then
      Mlog:error("Invalid UTF-8 character")
      return
    end
    return 3
  elseif 240 <= c and c <= 244 then
    local c2 = s:byte(i + 1)
    local c3 = s:byte(i + 2)
    local c4 = s:byte(i + 3)
    if not (c2 and c3) or not c4 then
      Mlog:error("UTF-8 string terminated early")
      return
    end
    if c == 240 and (c2 < 144 or 191 < c2) then
      Mlog:error("Invalid UTF-8 character")
      return
    elseif c == 244 and (c2 < 128 or 143 < c2) then
      Mlog:error("Invalid UTF-8 character")
      return
    elseif c2 < 128 or 191 < c2 then
      Mlog:error("Invalid UTF-8 character")
      return
    end
    if c3 < 128 or 191 < c3 then
      Mlog:error("Invalid UTF-8 character")
      return
    end
    if c4 < 128 or 191 < c4 then
      Mlog:error("Invalid UTF-8 character")
      return
    end
    return 4
  else
    Mlog:error("Invalid UTF-8 character")
  end
end

function string.formatnumberthousands(num)
  local formatted = tostring(checknumber(num))
  local k
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", "%1,%2")
    if k == 0 then
      break
    end
  end
  return formatted
end

function string.IsNullOrEmpty(str)
  return str == nil or str == ""
end

function string.startsWith(str, substr)
  if str == nil or substr == nil then
    return nil
  end
  return string.find(str, substr) == 1
end

function string.endsWith(str, substr)
  if str == nil or substr == nil then
    return nil
  end
  local str_tmp = string.reverse(str)
  local substr_tmp = string.reverse(substr)
  return string.find(str_tmp, substr_tmp) == 1
end

function string.replace(s, pattern, repl)
  local i, j = string.find(s, pattern, 1, true)
  if i and j then
    local ret = {}
    local start = 1
    while i and j do
      table.insert(ret, string.sub(s, start, i - 1))
      table.insert(ret, repl)
      start = j + 1
      i, j = string.find(s, pattern, start, true)
    end
    table.insert(ret, string.sub(s, start))
    return table.concat(ret)
  end
  return s
end

local iMATH_KF_RAD_TO_DEG = 57.29577950560105
local iMATH_KF_DEG_TO_RAD = 0.017453292522222223

function getDistance(x1, y1, x2, y2)
  return math.roundfloor(math.sqrt((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)), 6)
end

function getDistanceByPoint(point1, point2)
  if point1 == nil or point2 == nil or point1.x == nil or point1.y == nil or point2.x == nil or point2.y == nil then
    return 0
  end
  return math.roundfloor(math.sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y)), 6)
end

function getDistanceSquare(x1, y1, x2, y2)
  return math.roundfloor((x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2), 6)
end

function getDistanceSquareByPoint(point1, point2)
  return math.roundfloor((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y), 6)
end

function getDistanceEasy(x1, y1, x2, y2)
  return math.max(math.abs(x1 - x2), math.abs(y1 - y2))
end

function iMath_Round(_fOp)
  local fResult = _fOp + 0.5
  return fResult
end

function checkWithLimitData(additionalData, baseData, limitRate)
  local ntemp = math.abs(additionalData)
  local nLimit = baseData * limitRate
  if ntemp > nLimit then
    if additionalData < 0 then
      additionalData = -nLimit
    else
      additionalData = nLimit
    end
  end
  return additionalData
end

function getVerticalRadio(src_pt1, src_pt2)
  local radio = -(src_pt2.x - src_pt1.x) / (src_pt1.y - src_pt2.y)
  return radio
end

function getRadio(src_pt1, src_pt2)
  local radio = (src_pt1.y - src_pt2.y) / (src_pt2.x - src_pt1.x)
  return radio
end

function getVecRectanglePt(vec_pt1, vec_pt2, recPt1, recPt2, recPt3, recPt4, exceptPt1, exceptPt2)
  local function checkPt(vPt1, vPt2, rPt1, rPt2)
    if exceptPt1 and exceptPt2 and rPt1.x == exceptPt1.x and rPt1.y == exceptPt1.y and rPt2.x == exceptPt2.x and rPt2.y == exceptPt2.y then
      return false
    end
    log.debug("-------------------------------------------------")
    log.debug("vec_pt1:" .. vec_pt1.x .. "  " .. vec_pt1.y)
    log.debug("vec_pt2:" .. vec_pt2.x .. "  " .. vec_pt2.y)
    log.debug("rPt1:" .. rPt1.x .. "  " .. rPt1.y)
    log.debug("rPt2:" .. rPt2.x .. "  " .. rPt2.y)
    local distanceR1 = getDistanceFromPointToLine(vPt1, vPt2, rPt1, true)
    local distanceR2 = getDistanceFromPointToLine(vPt1, vPt2, rPt2, true)
    log.debug("distanceR1:" .. distanceR1)
    log.debug("distanceR2:" .. distanceR2)
    if distanceR1 * distanceR2 <= 0 then
      local distanceV1 = getDistanceFromPointToLine(rPt1, rPt2, vPt1, true)
      local distanceV2 = getDistanceFromPointToLine(rPt1, rPt2, vPt2, true)
      log.debug("distanceV1:" .. distanceV1)
      log.debug("distanceV2:" .. distanceV2)
      if distanceV1 * distanceV2 < 0 or math.abs(distanceV2) < math.abs(distanceV1) then
        return true, distanceV1, distanceV2
      end
    end
    return false
  end
  
  local find = false
  local dis1 = 0
  local dis2 = 0
  local findrPt1 = recPt1
  local findrPt2 = recPt2
  find, dis1, dis2 = checkPt(vec_pt1, vec_pt2, findrPt1, findrPt2)
  if find == false then
    findrPt1 = recPt2
    findrPt2 = recPt3
    find, dis1, dis2 = checkPt(vec_pt1, vec_pt2, findrPt1, findrPt2)
  end
  if find == false then
    findrPt1 = recPt3
    findrPt2 = recPt4
    find, dis1, dis2 = checkPt(vec_pt1, vec_pt2, findrPt1, findrPt2)
  end
  if find == false then
    findrPt1 = recPt4
    findrPt2 = recPt1
    find, dis1, dis2 = checkPt(vec_pt1, vec_pt2, findrPt1, findrPt2)
  end
  if find == true then
    local targetPt = cc.p(0, 0)
    if 0 < dis2 * dis1 then
      local rate = 1 - math.abs(dis2) / math.abs(dis1)
      targetPt.x = vec_pt1.x + (vec_pt2.x - vec_pt1.x) / rate
      targetPt.y = vec_pt1.y + (vec_pt2.y - vec_pt1.y) / rate
    else
      local rate = math.abs(dis1) / (math.abs(dis1) + math.abs(dis2))
      targetPt.x = vec_pt1.x + (vec_pt2.x - vec_pt1.x) * rate
      targetPt.y = vec_pt1.y + (vec_pt2.y - vec_pt1.y) * rate
    end
    return targetPt, findrPt1, findrPt2
  end
  return nil
end

function getMirrorPtFromRadio(src_pt1, src_pt2, src_pt3)
  local distance = getDistanceFromPointToLine(src_pt1, src_pt2, src_pt3, true)
  local vRadio = getVerticalRadio(src_pt1, src_pt2)
  local tPt1 = getPointFromRatio(src_pt3, vRadio, math.abs(distance) * 2, false)
  local tPt2 = getPointFromRatio(src_pt3, vRadio, math.abs(distance) * 2, true)
  local distance1 = getDistanceFromPointToLine(src_pt1, src_pt2, tPt1, true)
  local distance2 = getDistanceFromPointToLine(src_pt1, src_pt2, tPt2, true)
  if distance1 * distance <= 0 then
    return tPt1
  else
    return tPt2
  end
end

function getMirrorPtFromVerticalRadio(src_pt1, src_pt2, src_pt3, src_pt4)
  local tempPt = getVerticalPtFromPointToLine(src_pt1, src_pt2, src_pt3)
  local distance = getDistanceFromPointToLine(src_pt3, tempPt, src_pt4, true)
  local radio = getRadio(src_pt1, src_pt2)
  local tPt1 = getPointFromRatio(src_pt3, radio, math.abs(distance) * 2, false)
  local tPt2 = getPointFromRatio(src_pt3, radio, math.abs(distance) * 2, true)
  local distance1 = getDistanceFromPointToLine(src_pt3, tempPt, tPt1, true)
  local distance2 = getDistanceFromPointToLine(src_pt3, tempPt, tPt2, true)
  if 0 <= distance1 * distance then
    return tPt1
  else
    return tPt2
  end
end

function getVerticalPtFromPointToLine(src_pt1, src_pt2, src_pt3)
  local distance = getDistanceFromPointToLine(src_pt1, src_pt2, src_pt3, true)
  local vRadio = getVerticalRadio(src_pt1, src_pt2)
  local tPt1 = getPointFromRatio(src_pt3, vRadio, math.abs(distance), false)
  local tPt2 = getPointFromRatio(src_pt3, vRadio, math.abs(distance), true)
  local distance1 = getDistanceFromPointToLine(src_pt1, src_pt2, tPt1, true)
  local distance2 = getDistanceFromPointToLine(src_pt1, src_pt2, tPt2, true)
  if math.abs(distance1) < math.abs(distance2) then
    return tPt1
  else
    return tPt2
  end
end

function getDistanceFromPointToLine(src_pt1, src_pt2, src_pt3, notNeedFloor)
  local pt1 = cc.p(math.floor(src_pt1.x), math.floor(src_pt1.y))
  local pt2 = cc.p(math.floor(src_pt2.x), math.floor(src_pt2.y))
  local pt3 = cc.p(math.floor(src_pt3.x), math.floor(src_pt3.y))
  if notNeedFloor == true then
    pt1 = cc.p(src_pt1.x, src_pt1.y)
    pt2 = cc.p(src_pt2.x, src_pt2.y)
    pt3 = cc.p(src_pt3.x, src_pt3.y)
  end
  local d = ((pt2.y - pt1.y) * pt3.x + (pt1.x - pt2.x) * pt3.y + (pt2.x * pt1.y - pt1.x * pt2.y)) / math.sqrt((pt2.y - pt1.y) * (pt2.y - pt1.y) + (pt1.x - pt2.x) * (pt1.x - pt2.x))
  return d
end

function getPointFromLineIn2D(pt1, pt2, distanceToPt2)
  local length = getDistance(pt1.x, pt1.z, pt2.x, pt2.z)
  if distanceToPt2 >= length then
    return pt2
  elseif math.abs(length - distanceToPt2) < 1.0E-4 then
    return pt2
  end
  if IsNumEqual(length, 0) then
    return pt2
  end
  local percent = (length - distanceToPt2) / length
  local pt3 = Vector3.New(0, 0, 0)
  pt3.x = pt1.x + (pt2.x - pt1.x) * percent
  pt3.y = 0
  pt3.z = pt1.z + (pt2.z - pt1.z) * percent
  return pt3
end

function getPointFromRay(pt1, pt2, distanceToPt2)
  local length = getDistance(pt1.x, pt1.y, pt2.x, pt2.y)
  if length < 1.0E-4 then
    return pt1
  elseif 1.0E-4 > math.abs(length - distanceToPt2) then
    return pt2
  end
  if IsNumEqual(length, 0) then
    return pt2
  end
  local percent = distanceToPt2 / length
  local pt3 = cc.p(0, 0)
  pt3.x = pt1.x + (pt2.x - pt1.x) * percent
  pt3.y = pt1.y + (pt2.y - pt1.y) * percent
  return pt3
end

function getPointFromRay2(pt1, pt2, distanceToPt2)
  if -1.0E-4 <= distanceToPt2 and distanceToPt2 <= 1.0E-4 then
    return pt2
  end
  local length = getDistance(pt1.x, pt1.y, pt2.x, pt2.y)
  if IsNumEqual(length, 0) then
    return pt2
  end
  local percent = distanceToPt2 / length
  local pt3 = cc.p(0, 0)
  pt3.x = pt2.x + (pt2.x - pt1.x) * percent
  pt3.y = pt2.y + (pt2.y - pt1.y) * percent
  return pt3
end

function getPointFromRatio(startPoint, ratio, destlen, revert)
  local newpos = cc.p(0, 0)
  newpos.x = math.sqrt(destlen * destlen / (1 + ratio * ratio))
  if revert == true then
    newpos.x = -newpos.x
  end
  newpos.y = ratio * newpos.x
  newpos.x = newpos.x + startPoint.x
  newpos.y = startPoint.y - newpos.y
  return newpos
end

function clacDirection(orginalPoint, targetPoint)
  local degAngle = math.atan2(-(targetPoint.y - orginalPoint.y), targetPoint.x - orginalPoint.x) * 180 / math.pi
  if degAngle < 0 then
    degAngle = degAngle + 360
  end
  return degAngle
end

function isDirectionFaceDown(direction)
  if 0 < direction and direction < 180 then
    return false
  end
  return true
end

function isDirectionFaceLeft(direction)
  if not direction then
    return false
  end
  if 90 <= direction and direction <= 270 then
    return true
  end
  return false
end

function getIntPart(x)
  if 0 <= x then
    return math.floor(x)
  else
    return math.ceil(x)
  end
end

function getFloatPart(x)
  if x > math.floor(x) then
    x = x * 10
    x = math.ceil(x)
    x = x / 10
    return tonumber(string.format("%0.1f", x))
  else
    return x
  end
end

function getFloatPart4(x)
  if x > math.floor(x) then
    return tonumber(string.format("%0.4f", x))
  else
    return x
  end
end

function IsNumEqual(x, y)
  if math.abs(x - y) < 1.0E-4 then
    return true
  end
  return false
end

function math.clamp(v, min, max)
  return math.min(math.max(v, min), max)
end

function math.isPointEqual(pt1, pt2)
  if pt1 == nil or pt2 == nil then
    return false
  end
  if IsNumEqual(pt1.x, pt2.x) and IsNumEqual(pt1.y, pt2.y) then
    return true
  end
  return false
end

function formatNumber(str)
  if string.len(str) <= 3 then
    return str
  else
    return formatNumber(string.sub(str, 1, string.len(str) - 3)) .. "," .. string.sub(str, string.len(str) - 3 + 1, -1)
  end
end

function registerViewCallback(logicObj, viewObj, strRegister)
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

function ForbidModifyValue(table, k, v)
  log.error("View set Logic value, k=" .. tostring(k) .. ", v=" .. tostring(v) .. ", call stack= " .. debug.traceback())
end

function readOnlyProxy(oriTable)
  local t = {}
  t.__index = oriTable
  t.__newindex = ForbidModifyValue
  local newTable = {}
  setmetatable(newTable, t)
  return newTable
end

function readOnlyProxyVector3(oriTable)
  local t = {}
  t.__index = oriTable
  t.__newindex = ForbidModifyValue
  t.__tostring = Vector3.__tostring
  t.__div = Vector3.__div
  t.__mul = Vector3.__mul
  t.__add = Vector3.__add
  t.__sub = Vector3.__sub
  t.__unm = Vector3.__unm
  t.__eq = Vector3.__eq
  local newTable = {}
  setmetatable(newTable, t)
  return newTable
end

function ShowValueChange(table, k, v)
  if k == "m_curPos" then
    log.error("value change, k=" .. tostring(k) .. ", v=" .. tostring(v))
  end
  rawset(table.m_oriTable, k, v)
end

function DetectValueChange(oriTable, fun)
  local t = {}
  t.__index = oriTable
  t.__newindex = fun or ShowValueChange
  local newTable = {}
  newTable.m_oriTable = oriTable
  setmetatable(newTable, t)
  return newTable
end

function PointinTriangle(P, A, B, C)
  local v0 = cc.pSub(C, A)
  local v1 = cc.pSub(B, A)
  local v2 = cc.pSub(P, A)
  local dot00 = cc.pDot(v0, v0)
  local dot01 = cc.pDot(v0, v1)
  local dot02 = cc.pDot(v0, v2)
  local dot11 = cc.pDot(v1, v1)
  local dot12 = cc.pDot(v1, v2)
  local inverDeno = 1 / (dot00 * dot11 - dot01 * dot01)
  local u = (dot11 * dot02 - dot01 * dot12) * inverDeno
  if u < 0 or 1 < u then
    return false
  end
  local v = (dot00 * dot12 - dot01 * dot02) * inverDeno
  if v < 0 or 1 < v then
    return false
  end
  return u + v <= 1
end

function clacEllipse(pos1, pos2, aRadius, bRadius)
  local x1 = pos1.x
  local y1 = pos1.y
  local x2 = pos2.x
  local y2 = pos2.y
  local a = aRadius
  local b = bRadius
  if math.abs(x1 - x2) > a + a then
    return nil
  end
  if math.abs(y1 - y2) > b + b then
    return nil
  end
  local r1 = (x1 - x2) / (2 * a)
  local r2 = (y2 - y1) / (2 * b)
  local ntotal = math.sqrt(r1 * r1 + r2 * r2)
  if ntotal < 0 or 1 < ntotal then
    return nil
  end
  local a2 = math.asin(ntotal)
  local a1 = math.atan(r1 / r2)
  local t1 = a1 + a2
  local t2 = a1 - a2
  local x0, y0
  if y1 <= y2 then
    x0 = x1 + a * math.cos(t1)
    y0 = y1 + b * math.sin(t1)
  else
    x0 = x1 - a * math.cos(t1)
    y0 = y1 - b * math.sin(t1)
  end
  return cc.p(x0, y0)
end

function swap(a, b)
  return b, a
end

function CreatEnumTable(tbl, index)
  local enumtbl = {}
  local enumindex = index or 0
  for i, v in ipairs(tbl) do
    enumtbl[v] = enumindex + i
  end
  return enumtbl
end

function switch(selector, case, ...)
  if case[selector] ~= nil then
    return case[selector](...)
  elseif case.default ~= nil then
    return case.default(...)
  else
    log.debug("unknow case by " .. selector)
  end
end

function isnan(x)
  return x ~= x
end

function iff(c, a, b)
  if c then
    return a
  else
    return b
  end
end

function DebugPrintTable(tab)
  local str = {}
  local processed = {}
  local key_chains = {}
  local key_chains_n = 0
  
  local function key_chains_init()
    processed[tab] = "[ROOT]"
    table.insert(key_chains, "[ROOT]")
    key_chains_n = 1
  end
  
  local function key_chains_push(k)
    table.insert(key_chains, key_chains_n + 1, tostring(k))
    key_chains_n = key_chains_n + 1
  end
  
  local function key_chains_pop()
    table.remove(key_chains, key_chains_n)
    key_chains_n = key_chains_n - 1
  end
  
  local function internal(tab, str, indent, isroot)
    if not isroot and processed[tab] then
      table.insert(str, indent .. processed[tab] .. "\n")
      return
    end
    processed[tab] = "[**Ref**]" .. table.concat(key_chains, ".")
    for k, v in pairs(tab) do
      if type(v) == "table" then
        table.insert(str, indent .. tostring(k) .. ":\n")
        key_chains_push(k)
        internal(v, str, indent .. "  ", false)
        key_chains_pop()
      else
        table.insert(str, indent .. tostring(k) .. ": " .. tostring(v) .. "\n")
      end
    end
  end
  
  key_chains_init()
  internal(tab, str, "", true)
  local info = debug.getinfo(2, "Sl")
  local desc = "______________DebugPrintTable: " .. info.source .. ", line:" .. info.currentline .. "__________\n" .. table.concat(str, "")
  log.debug(desc)
end

function bezierat(a, b, c, d, t)
  return Mathf.pow(1 - t, 3) * a + 3 * t * Mathf.pow(1 - t, 2) * b + 3 * Mathf.pow(t, 2) * (1 - t) * c + Mathf.pow(t, 3) * d
end

function GetAngleDegree(vecDest, vecSrc)
  vecDest = vecDest:Normalize()
  vecSrc = vecSrc:Normalize()
  local fDot = Vector3.Dot(vecDest, vecSrc)
  local fDegree = math.acos(fDot)
  return 180.0 * fDegree / math.pi
end

function LineIntersectsWithCircle(p1, p2, p3, r)
  local A = (p2.x - p1.x) * (p2.x - p1.x) + (p2.z - p1.z) * (p2.z - p1.z)
  local B = 2 * ((p2.x - p1.x) * (p1.x - p3.x) + (p2.z - p1.z) * (p1.z - p3.z))
  local C = p3.x * p3.x + p3.z * p3.z + p1.x * p1.x + p1.z * p1.z - 2 * (p3.x * p1.x + p3.z * p1.z) - r * r
  local D = B * B - 4 * A * C
  if D < 0 then
    return nil
  end
  local d = math.sqrt(D)
  local u1 = (-B + d) / (2 * A)
  local u2 = (-B - d) / (2 * A)
  local point1
  if 0 <= u1 and u1 <= 1 then
    point1 = Vector3.New(0, 0, 0)
    point1.x = p1.x + u1 * (p2.x - p1.x)
    point1.z = p1.z + u1 * (p2.z - p1.z)
  end
  local point2
  if 0 <= u2 and u2 <= 1 and u2 ~= u1 then
    point2 = Vector3.New(0, 0, 0)
    point2.x = p1.x + u2 * (p2.x - p1.x)
    point2.z = p1.z + u2 * (p2.z - p1.z)
  end
  return point1, point2
end

function dblcmp(a, b)
  if IsNumEqual(a, b) then
    return 0
  end
  if b < a then
    return 1
  else
    return -1
  end
end

function dot(x1, z1, x2, z2)
  return x1 * x2 + z1 * z2
end

function point_on_line(a, b, c)
  return dblcmp(dot(b.x - a.x, b.z - a.z, c.x - a.x, c.z - a.z), 0)
end

function cross(x1, z1, x2, z2)
  return x1 * z2 - x2 * z1
end

function ab_cross_ac(a, b, c)
  return cross(b.x - a.x, b.z - a.z, c.x - a.x, c.z - a.z)
end

function LineIntersectsWithLine(a, b, c, d)
  local s1 = ab_cross_ac(a, b, c)
  local s2 = ab_cross_ac(a, b, d)
  local s3 = ab_cross_ac(c, d, a)
  local s4 = ab_cross_ac(c, d, b)
  local d1 = dblcmp(s1, 0)
  local d2 = dblcmp(s2, 0)
  local d3 = dblcmp(s3, 0)
  local d4 = dblcmp(s4, 0)
  if (d1 == 1 and d2 == -1 or d1 == -1 and d2 == 1) and (d3 == 1 and d4 == -1 or d3 == -1 and d4 == 1) then
    local p = Vector3.New(0, 0, 0)
    p.x = (c.x * s2 - d.x * s1) / (s2 - s1)
    p.z = (c.z * s2 - d.z * s1) / (s2 - s1)
    return p
  end
  if d1 == 0 and 0 >= point_on_line(c, a, b) then
    local p = c:Clone()
    return p
  end
  if d2 == 0 and 0 >= point_on_line(d, a, b) then
    local p = d:Clone()
    return p
  end
  if d3 == 0 and 0 >= point_on_line(a, c, d) then
    local p = a:Clone()
    return p
  end
  if d4 == 0 and 0 >= point_on_line(b, c, d) then
    local p = b:Clone()
    return p
  end
  return nil
end

function worldToUIPoint(camera, worldPos)
  local v_ui = camera:GetComponent("Camera"):ScreenToWorldPoint(worldPos)
  return v_ui
end

function instantiate(go)
  local aObj = CS.UnityEngine.GameObject.Instantiate(go)
  return aObj
end

function instantiateToParent(go, parentGo)
  local aObj = CS.UnityEngine.GameObject.Instantiate(go, parentGo)
  return aObj
end

function instantiateToParentInWorldSpace(go, parentGo, bInWorldSpace)
  local aObj = CS.UnityEngine.GameObject.Instantiate(go, parentGo, bInWorldSpace)
  return aObj
end

require("common/Vector3")
require("common/Vector2")
local v3 = Vector3.New(0, 0, 0)

function GetTempVector3(x, y, z)
  v3:Set(x, y, z)
  return v3
end

local v2 = Vector2.New(0, 0)

function GetTempVector2(x, y)
  v2:Set(x, y)
  return v2
end

local v4 = Vector3.New(0, 0, 0)

function SetPositionXYZ(trans, x, y, z)
  v4:Set(x, y, z)
  trans.position = v4
end

function SetLocalPositionXYZ(trans, x, y, z)
  v4:Set(x, y, z)
  trans.localPosition = v4
end

function SetAnchoredPosition(trans, x, y)
  v2:Set(x, y)
  trans.anchoredPosition = v2
end

function SetScaleXYZ(trans, x, y, z)
  v4:Set(x, y, z)
  trans.scale = v4
end

function SetLocalScaleXYZ(trans, x, y, z)
  v4:Set(x, y, z)
  trans.localScale = v4
end

function Replace(str, pattern, substring)
  substring = string.gsub(substring, "%%", "%%%%")
  return string.gsub(str, pattern, substring)
end

function invoke_s(method, ...)
  _ = method and method(...)
end

placeholder = {
  _1 = {},
  _2 = {},
  _3 = {},
  _4 = {},
  _5 = {},
  _6 = {},
  _7 = {},
  _8 = {}
}
local __ph_table = {
  placeholder._1,
  placeholder._2,
  placeholder._3,
  placeholder._4,
  placeholder._5,
  placeholder._6,
  placeholder._7,
  placeholder._8
}

function bind(method, ...)
  local args = {
    size = select("#", ...),
    ...
  }
  local n = 1
  local replace_list = {}
  for i = 1, args.size do
    if args[i] == __ph_table[n] then
      replace_list[n] = i
      n = n + 1
    end
  end
  return function(...)
    for i = 1, n - 1 do
      args[replace_list[i]] = select(i, ...)
    end
    invoke_s(method, unpack(args, 1, args.size))
  end
end

function PRINT_VECTOR(v, tag)
  log.debug(tag .. " : " .. v.x .. ", " .. v.y .. ", " .. (v.z or 0))
end

function CreateTable(length)
  local mytabel = {}
  for i = 1, length do
    mytabel[i] = i
  end
  return mytabel
end

math.deg2Rad = math.pi / 180
math.rad2Deg = 180 / math.pi

local function CheckFunction(func)
  if func then
    local type_f = type(func)
    return type_f == "function"
  end
end

function TryCatch(try, catch, finally)
  if not try then
    log.error("try function is nil")
    return
  end
  if not CheckFunction(try) then
    log.error("try is not a function")
    return
  end
  local ok, errors = xpcall(try, debug.traceback)
  if not ok then
    log.error(tostring(errors))
    if catch and CheckFunction(catch) then
      pcall(catch, errors)
    end
  end
  if finally and CheckFunction(finally) then
    pcall(finally, ok, errors)
  end
  if ok then
    return errors
  end
end

function string.split(input, sep1)
  local str = ""
  input = tostring(input)
  sep1 = tostring(sep1)
  if sep1 == "" then
    return false
  end
  local pos, arr = 0, {}
  for st, sp in function()
    return string.find(input, sep1, pos, true)
  end, nil, nil do
    str = string.sub(input, pos, st - 1)
    if str ~= "" then
      table.insert(arr, str)
    end
    pos = sp + 1
  end
  str = string.sub(input, pos)
  if str ~= "" then
    table.insert(arr, str)
  end
  return arr
end

function string.splitArr(input, sep1, sep2)
  local retArr = {}
  sep1 = sep1 or ";"
  sep2 = sep2 or ","
  local sep1arr = string.split(input, sep1)
  local index = 1
  for _, v in pairs(sep1arr) do
    local sep2arr = string.split(v, sep2)
    retArr[index] = sep2arr
    index = index + 1
  end
  return retArr
end

function World2UI(UICamera, wpos, uiParent)
  local uiScreenPosition = UICamera:WorldToScreenPoint(wpos)
  local tempv2 = Vector2.New(uiScreenPosition.x, uiScreenPosition.y)
  local inRect, anchpos = CS.UnityEngine.RectTransformUtility.ScreenPointToLocalPointInRectangle(uiParent, tempv2, UICamera)
  return anchpos
end

function string.gsubNumberReplace(str, ...)
  local arg = {
    ...
  }
  str = string.gsub(str, "{(%d+)}", function(idx)
    return arg[idx + 1]
  end)
  return str
end

function string.customizeReplace(str, seps, ...)
  local arg = {
    ...
  }
  for i, v in ipairs(seps) do
    str = string.gsub(str, v, arg[i])
  end
  return str
end

function ResourceNumFormat(num)
  if 1000000000 <= num then
    return string.format("%.2fB", num / 1000000000)
  elseif 1000000 <= num then
    local value = num / 1000000
    if 100 < value then
      return string.format("%dM", math.floor(value))
    elseif 10 < value then
      return string.format("%.1fM", value)
    else
      return string.format("%.2fM", value)
    end
  elseif 10000 <= num then
    local value = num / 1000
    if 100 < value then
      return string.format("%dK", math.floor(value))
    else
      return string.format("%.1fK", value)
    end
  else
    return tostring(num)
  end
end

function BigNumFormatPayItem(num)
  if not num then
    return "0"
  end
  local str = tostring(num)
  local integer, decimal = str:match("^(%d*)(%.?%d*)$")
  integer = integer:reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
  return integer .. decimal
end

function BigNumFormat(num)
  local isCN = ChannelManager:IsChinaChannel()
  if isCN then
    if 100000000 <= num then
      local tempValue = math.floor(num / 10000000)
      local value = tempValue / 10
      local showValue = value == math.floor(value) and math.floor(value) or value
      local str = ConfigManager:GetCNUnit(showValue, 2)
      return str
    elseif 1000000 <= num then
      local tempValue = math.floor(num / 1000)
      local value = tempValue / 10
      local showValue = value == math.floor(value) and math.floor(value) or value
      local str = ConfigManager:GetCNUnit(showValue, 1)
      return str
    elseif 1 <= num then
      return tostring(math.floor(num))
    else
      return tostring(num)
    end
  end
  if 2100000000 <= num then
    local value = num / 1000000
    return string.format("%dM", math.floor(value))
  elseif 100000000 <= num then
    local value = num / 1000000
    return string.format("%dM", math.floor(value))
  elseif 100000 <= num then
    local value = num / 1000
    return string.format("%dK", math.floor(value))
  elseif 1 <= num then
    return tostring(math.floor(num))
  else
    return tostring(num)
  end
end

function tableToJson(tbl)
  local jsonStr = "{"
  local isFirst = true
  for key, value in pairs(tbl) do
    if not isFirst then
      jsonStr = jsonStr .. ","
    end
    jsonStr = jsonStr .. "\"" .. key .. "\":"
    if type(value) == "string" then
      jsonStr = jsonStr .. "\"" .. value .. "\""
    elseif type(value) == "number" or type(value) == "boolean" then
      jsonStr = jsonStr .. tostring(value)
    elseif type(value) == "table" then
      jsonStr = jsonStr .. tableToJson(value)
    end
    isFirst = false
  end
  jsonStr = jsonStr .. "}"
  return jsonStr
end

local _id = 0

function getIncID()
  _id = _id + 1
  return _id
end

function isfunction(f)
  return type(f) == "function"
end

function istable(t)
  return type(t) == "table"
end

function isstring(s)
  return type(s) == "string"
end

function isnumber(n)
  return type(n) == "number"
end

function IsNil(uobj)
  return uobj == nil or uobj:Equals(nil)
end

function ErrorHandler(err)
  local trace = debug.traceback(err)
  log.error("Lua Exception:\n" .. trace)
end

function typeof(t)
  return t.UnderlyingSystemType
end
