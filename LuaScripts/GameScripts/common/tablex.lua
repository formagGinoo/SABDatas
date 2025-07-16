local utils = require("common/utils")
local types = require("common/types")
local getmetatable, setmetatable, require = getmetatable, setmetatable, _ENV.require
local tsort, append, remove = table.sort, table.insert, table.remove
local min = math.min
local pairs, type, unpack, select, tostring = pairs, type, utils.unpack, select, _ENV.tostring
local function_arg = utils.function_arg
local assert_arg = utils.assert_arg

local function setmeta(res, tbl, pl_class)
  local mt = getmetatable(tbl) or pl_class and require("common/" .. pl_class)
  return mt and setmetatable(res, mt) or res
end

local function makelist(l)
  return setmetatable(l, require("common/List"))
end

local function complain(idx, msg)
  error(("argument %d is not %s"):format(idx, msg), 3)
end

local function assert_arg_indexable(idx, val)
  if not types.is_indexable(val) then
    complain(idx, "indexable")
  end
end

local function assert_arg_iterable(idx, val)
  if not types.is_iterable(val) then
    complain(idx, "iterable")
  end
end

local function assert_arg_writeable(idx, val)
  if not types.is_writeable(val) then
    complain(idx, "writeable")
  end
end

function table.update(t1, t2)
  assert_arg_writeable(1, t1)
  assert_arg_iterable(2, t2)
  for k, v in pairs(t2) do
    t1[k] = v
  end
  return t1
end

function table.size(t)
  assert_arg_iterable(1, t)
  local i = 0
  for k in pairs(t) do
    i = i + 1
  end
  return i
end

function table.copy(t)
  assert_arg_iterable(1, t)
  local res = {}
  for k, v in pairs(t) do
    res[k] = v
  end
  return res
end

local function cycle_aware_copy(t, cache)
  if type(t) ~= "table" then
    return t
  end
  if cache[t] then
    return cache[t]
  end
  assert_arg_iterable(1, t)
  local res = {}
  cache[t] = res
  local mt = getmetatable(t)
  for k, v in pairs(t) do
    k = cycle_aware_copy(k, cache)
    v = cycle_aware_copy(v, cache)
    res[k] = v
  end
  setmetatable(res, mt)
  return res
end

function table.deepcopy(t)
  return cycle_aware_copy(t, {})
end

local abs = math.abs

local function cycle_aware_compare(t1, t2, ignore_mt, eps, cache)
  if cache[t1] and cache[t1][t2] then
    return true
  end
  local ty1 = type(t1)
  local ty2 = type(t2)
  if ty1 ~= ty2 then
    return false
  end
  if ty1 ~= "table" then
    if ty1 == "number" and eps then
      return eps > abs(t1 - t2)
    end
    return t1 == t2
  end
  local mt = getmetatable(t1)
  if not ignore_mt and mt and mt.__eq then
    return t1 == t2
  end
  for k1 in pairs(t1) do
    if t2[k1] == nil then
      return false
    end
  end
  for k2 in pairs(t2) do
    if t1[k2] == nil then
      return false
    end
  end
  cache[t1] = cache[t1] or {}
  cache[t1][t2] = true
  for k1, v1 in pairs(t1) do
    local v2 = t2[k1]
    if not cycle_aware_compare(v1, v2, ignore_mt, eps, cache) then
      return false
    end
  end
  return true
end

function table.deepcompare(t1, t2, ignore_mt, eps)
  return cycle_aware_compare(t1, t2, ignore_mt, eps, {})
end

function table.compare(t1, t2, cmp)
  assert_arg_indexable(1, t1)
  assert_arg_indexable(2, t2)
  if #t1 ~= #t2 then
    return false
  end
  cmp = function_arg(3, cmp)
  for k = 1, #t1 do
    if not cmp(t1[k], t2[k]) then
      return false
    end
  end
  return true
end

function table.compare_no_order(t1, t2, cmp)
  assert_arg_indexable(1, t1)
  assert_arg_indexable(2, t2)
  cmp = cmp and function_arg(3, cmp)
  if #t1 ~= #t2 then
    return false
  end
  local visited = {}
  for i = 1, #t1 do
    local val = t1[i]
    local gotcha
    for j = 1, #t2 do
      if not visited[j] then
        local match
        if cmp then
          match = cmp(val, t2[j])
        else
          match = val == t2[j]
        end
        if match then
          gotcha = j
          break
        end
      end
    end
    if not gotcha then
      return false
    end
    visited[gotcha] = true
  end
  return true
end

function table.find(t, val, idx)
  assert_arg_indexable(1, t)
  idx = idx or 1
  if idx < 0 then
    idx = #t + idx + 1
  end
  for i = idx, #t do
    if t[i] == val then
      return i
    end
  end
  return nil
end

function table.rfind(t, val, idx)
  assert_arg_indexable(1, t)
  idx = idx or #t
  if idx < 0 then
    idx = #t + idx + 1
  end
  for i = idx, 1, -1 do
    if t[i] == val then
      return i
    end
  end
  return nil
end

function table.find_if(t, cmp, arg)
  assert_arg_iterable(1, t)
  cmp = function_arg(2, cmp)
  for k, v in pairs(t) do
    local c = cmp(v, arg)
    if c then
      return k, c
    end
  end
  return nil
end

function table.index_by(tbl, idx)
  assert_arg_indexable(1, tbl)
  assert_arg_indexable(2, idx)
  local res = {}
  for i = 1, #idx do
    res[i] = tbl[idx[i]]
  end
  return setmeta(res, tbl, "List")
end

function table.map(fun, t, ...)
  assert_arg_iterable(1, t)
  fun = function_arg(1, fun)
  local res = {}
  for k, v in pairs(t) do
    res[k] = fun(v, ...)
  end
  return setmeta(res, t)
end

function table.imap(fun, t, ...)
  assert_arg_indexable(1, t)
  fun = function_arg(1, fun)
  local res = {}
  for i = 1, #t do
    res[i] = fun(t[i], ...) or false
  end
  return setmeta(res, t, "List")
end

function table.map_named_method(name, t, ...)
  utils.assert_string(1, name)
  assert_arg_indexable(2, t)
  local res = {}
  for i = 1, #t do
    local val = t[i]
    local fun = val[name]
    res[i] = fun(val, ...)
  end
  return setmeta(res, t, "List")
end

function table.transform(fun, t, ...)
  assert_arg_iterable(1, t)
  fun = function_arg(1, fun)
  for k, v in pairs(t) do
    t[k] = fun(v, ...)
  end
end

function table.range(start, finish, step)
  local res
  step = step or 1
  if start == finish then
    res = {start}
  elseif finish < start and 0 < step or start < finish and step < 0 then
    res = {}
  else
    local k = 1
    res = {}
    for i = start, finish, step do
      res[k] = i
      k = k + 1
    end
  end
  return makelist(res)
end

function table.map2(fun, t1, t2, ...)
  assert_arg_iterable(1, t1)
  assert_arg_iterable(2, t2)
  fun = function_arg(1, fun)
  local res = {}
  for k, v in pairs(t1) do
    res[k] = fun(v, t2[k], ...)
  end
  return setmeta(res, t1, "List")
end

function table.imap2(fun, t1, t2, ...)
  assert_arg_indexable(2, t1)
  assert_arg_indexable(3, t2)
  fun = function_arg(1, fun)
  local res, n = {}, math.min(#t1, #t2)
  for i = 1, n do
    res[i] = fun(t1[i], t2[i], ...)
  end
  return res
end

function table.reduce(fun, t, memo)
  assert_arg_indexable(2, t)
  fun = function_arg(1, fun)
  local n = #t
  if n == 0 then
    return memo
  end
  local res = memo and fun(memo, t[1]) or t[1]
  for i = 2, n do
    res = fun(res, t[i])
  end
  return res
end

function table.foreach(t, fun, ...)
  assert_arg_iterable(1, t)
  fun = function_arg(2, fun)
  for k, v in pairs(t) do
    fun(v, k, ...)
  end
end

function table.foreachi(t, fun, ...)
  assert_arg_indexable(1, t)
  fun = function_arg(2, fun)
  for i = 1, #t do
    fun(t[i], i, ...)
  end
end

function table.mapn(fun, ...)
  fun = function_arg(1, fun)
  local res = {}
  local lists = {
    ...
  }
  local minn = 1.0E40
  for i = 1, #lists do
    minn = min(minn, #lists[i])
  end
  for i = 1, minn do
    local args, k = {}, 1
    for j = 1, #lists do
      args[k] = lists[j][i]
      k = k + 1
    end
    res[#res + 1] = fun(unpack(args))
  end
  return res
end

function table.pairmap(fun, t, ...)
  assert_arg_iterable(1, t)
  fun = function_arg(1, fun)
  local res = {}
  for k, v in pairs(t) do
    local rv, rk = fun(k, v, ...)
    if rk then
      if res[rk] then
        if type(res[rk]) == "table" then
          table.insert(res[rk], rv)
        else
          res[rk] = {
            res[rk],
            rv
          }
        end
      else
        res[rk] = rv
      end
    else
      res[#res + 1] = rv
    end
  end
  return res
end

local function keys_op(i, v)
  return i
end

function table.keys(t)
  assert_arg_iterable(1, t)
  return makelist(table.pairmap(keys_op, t))
end

local function values_op(i, v)
  return v
end

function table.values(t)
  assert_arg_iterable(1, t)
  return makelist(table.pairmap(values_op, t))
end

function table.merge(t1, t2, dup)
  assert_arg_iterable(1, t1)
  assert_arg_iterable(2, t2)
  local res = {}
  for k, v in pairs(t1) do
    if dup or t2[k] then
      res[k] = v
    end
  end
  if dup then
    for k, v in pairs(t2) do
      res[k] = v
    end
  end
  return setmeta(res, t1)
end

function table.union(t1, t2)
  return table.merge(t1, t2, true)
end

function table.intersection(t1, t2)
  return table.merge(t1, t2, false)
end

function table.difference(s1, s2, symm)
  assert_arg_iterable(1, s1)
  assert_arg_iterable(2, s2)
  local res = {}
  for k, v in pairs(s1) do
    if s2[k] == nil then
      res[k] = v
    end
  end
  if symm then
    for k, v in pairs(s2) do
      if s1[k] == nil then
        res[k] = v
      end
    end
  end
  return setmeta(res, s1)
end

function table.filter(t, pred, arg)
  assert_arg_indexable(1, t)
  pred = function_arg(2, pred)
  local res, k = {}, 1
  for i = 1, #t do
    local v = t[i]
    if pred(v, arg) then
      res[k] = v
      k = k + 1
    end
  end
  return setmeta(res, t, "List")
end

function table.zip(...)
  return table.mapn(function(...)
    return {
      ...
    }
  end, ...)
end

local _copy

function _copy(dest, src, idest, isrc, nsrc, clean_tail)
  idest = idest or 1
  isrc = isrc or 1
  local iend
  if not nsrc then
    nsrc = #src
    iend = #src
  else
    iend = isrc + min(nsrc - 1, #src - isrc)
  end
  if dest == src and idest > isrc and idest <= iend then
    src = table.sub(src, isrc, nsrc)
    isrc = 1
    iend = #src
  end
  for i = isrc, iend do
    dest[idest] = src[i]
    idest = idest + 1
  end
  if clean_tail then
    table.clear(dest, idest)
  end
  return dest
end

function table.icopy(dest, src, idest, isrc, nsrc)
  assert_arg_indexable(1, dest)
  assert_arg_indexable(2, src)
  return _copy(dest, src, idest, isrc, nsrc, true)
end

function table.move(dest, src, idest, isrc, nsrc)
  assert_arg_indexable(1, dest)
  assert_arg_indexable(2, src)
  return _copy(dest, src, idest, isrc, nsrc, false)
end

function table:_normalize_slice(first, last)
  local sz = #self
  first = first or 1
  if first < 0 then
    first = sz + first + 1
  end
  last = last or sz
  if last < 0 then
    last = sz + 1 + last
  end
  return first, last
end

function table.sub(t, first, last)
  assert_arg_indexable(1, t)
  first, last = table._normalize_slice(t, first, last)
  local res = {}
  for i = first, last do
    append(res, t[i])
  end
  return setmeta(res, t, "List")
end

function table.set(t, val, i1, i2)
  assert_arg_indexable(1, t)
  i1, i2 = i1 or 1, i2 or #t
  if types.is_callable(val) then
    for i = i1, i2 do
      t[i] = val(i)
    end
  else
    for i = i1, i2 do
      t[i] = val
    end
  end
end

function table.new(n, val)
  local res = {}
  table.set(res, val, 1, n)
  return res
end

function table.clear(t, istart)
  istart = istart or 1
  for i = istart, #t do
    remove(t)
  end
end

function table.insertvalues(t, ...)
  assert_arg(1, t, "table")
  local pos, values
  if select("#", ...) == 1 then
    pos, values = #t + 1, (...)
  else
    pos, values = ...
  end
  if 0 < #values then
    for i = #t, pos, -1 do
      t[i + #values] = t[i]
    end
    local offset = 1 - pos
    for i = pos, pos + #values - 1 do
      t[i] = values[i + offset]
    end
  end
  return t
end

function table.removevalues(t, i1, i2)
  assert_arg(1, t, "table")
  i1, i2 = table._normalize_slice(t, i1, i2)
  for i = i1, i2 do
    remove(t, i1)
  end
  return t
end

local _find

function _find(t, value, tables)
  for k, v in pairs(t) do
    if v == value then
      return k
    end
  end
  for k, v in pairs(t) do
    if not tables[v] and type(v) == "table" then
      tables[v] = true
      local res = _find(v, value, tables)
      if res then
        res = tostring(res)
        if type(k) ~= "string" then
          return "[" .. k .. "]" .. res
        else
          return k .. "." .. res
        end
      end
    end
  end
end

function table.search(t, value, exclude)
  assert_arg_iterable(1, t)
  local tables = {
    [t] = true
  }
  if exclude then
    for _, v in pairs(exclude) do
      tables[v] = true
    end
  end
  return _find(t, value, tables)
end

function table.sortk(t, f)
  local keys = {}
  for k in pairs(t) do
    keys[#keys + 1] = k
  end
  tsort(keys, f)
  local i = 0
  return function()
    i = i + 1
    return keys[i], t[keys[i]]
  end
end

function table.sortv(t, f)
  f = function_arg(2, f or "<")
  local keys = {}
  for k in pairs(t) do
    keys[#keys + 1] = k
  end
  tsort(keys, function(x, y)
    return f(t[x], t[y])
  end)
  local i = 0
  return function()
    i = i + 1
    return keys[i], t[keys[i]]
  end
end

function table.readonly(t)
  local mt = {
    __index = t,
    __newindex = function(t, k, v)
      error("Attempt to modify read-only table", 2)
    end,
    __pairs = function()
      return pairs(t)
    end,
    __ipairs = function()
      return ipairs(t)
    end,
    __len = function()
      return #t
    end,
    __metatable = false
  }
  return setmetatable({}, mt)
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

function table.insertto(dest, src, begin)
  begin = math.checkint(begin)
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
  return -1
end

function table.keyof(hashtable, value)
  for k, v in pairs(hashtable) do
    if v == value then
      return k
    end
  end
  return nil
end

function table.valueof(hashtable, key)
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

function table.walk(t, fn)
  for k, v in pairs(t) do
    fn(v, k)
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

local function isarray(t)
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
    if isarray(t) then
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

function table.serializedebug(t)
  if GameSettings.m_bIsDebugMode == true then
    local s = table.serialize(t) or " "
    return string.gsub(s, "%%", "*")
  else
    return ""
  end
end

function table.serializeformat(root, indent, allKeys)
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

function table.removetablekey(tbl)
  for k, v in pairs(tbl) do
    if type(k) == "table" then
      tbl[k] = nil
    elseif type(v) == "table" then
      table.removetablekey(v)
    end
  end
  return tbl
end

local function forbidmodifyvalue(table, k, v)
  log.error("View set Logic value, k=" .. tostring(k) .. ", v=" .. tostring(v) .. ", call stack= " .. debug.traceback())
end

function table.readonlyproxy(oriTable)
  local t = {}
  t.__index = oriTable
  t.__newindex = forbidmodifyvalue
  local newTable = {}
  setmetatable(newTable, t)
  return newTable
end

function table.readonlyproxyvector3(oriTable)
  local t = {}
  t.__index = oriTable
  t.__newindex = forbidmodifyvalue
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

local function showvaluechange(table, k, v)
  if k == "m_curPos" then
    log.error("value change, k=" .. tostring(k) .. ", v=" .. tostring(v))
  end
  rawset(table.m_oriTable, k, v)
end

function table.detectValueChange(oriTable, fun)
  local t = {}
  t.__index = oriTable
  t.__newindex = fun or showvaluechange
  local newTable = {}
  newTable.m_oriTable = oriTable
  setmetatable(newTable, t)
  return newTable
end

function table.createtable(length)
  local mytabel = {}
  for i = 1, length do
    mytabel[i] = i
  end
  return mytabel
end

function table.clone(object)
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

function table.createnumtable(tbl, index)
  local enumtbl = {}
  local enumindex = index or 0
  for i, v in ipairs(tbl) do
    enumtbl[v] = enumindex + i
  end
  return enumtbl
end

function table.debugprintable(tab)
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
