local next, assert, pairs, tonumber, type, setmetatable = next, assert, pairs, tonumber, type, _ENV.setmetatable
local strfind, format = string.find, string.format
local mrandom = math.random
local tsort, tappend = table.sort, table.insert
local io = _ENV.io
local utils = require("common/utils")
local callable = require("common/types").is_callable
local function_arg = utils.function_arg
local assert_arg = utils.assert_arg
local debug = require("debug")
local seq = {}

function seq.greater_than(x)
  return function(v)
    return tonumber(v) > x
  end
end

function seq.less_than(x)
  return function(v)
    return tonumber(v) < x
  end
end

function seq.equal_to(x)
  if type(x) == "number" then
    return function(v)
      return tonumber(v) == x
    end
  else
    return function(v)
      return v == x
    end
  end
end

function seq.matching(s)
  return function(v)
    return strfind(v, s)
  end
end

local nexti

function seq.list(t)
  assert_arg(1, t, "table")
  if not nexti then
    nexti = ipairs({})
  end
  local key, value = 0
  return function()
    key, value = nexti(t, key)
    return value
  end
end

function seq.keys(t)
  assert_arg(1, t, "table")
  local key
  return function()
    key = next(t, key)
    return key
  end
end

local list = seq.list

local function default_iter(iter)
  if type(iter) == "table" then
    return list(iter)
  else
    return iter
  end
end

seq.iter = default_iter

function seq.range(start, finish)
  local i = start - 1
  return function()
    i = i + 1
    if i > finish then
      return nil
    else
      return i
    end
  end
end

function seq.count(iter, condn, arg)
  local i = 0
  seq.foreach(iter, function(val)
    if condn(val, arg) then
      i = i + 1
    end
  end)
  return i
end

function seq.minmax(iter)
  local vmin, vmax = 1.0E70, -1.0E70
  for v in default_iter(iter) do
    v = tonumber(v)
    if vmin > v then
      vmin = v
    end
    if vmax < v then
      vmax = v
    end
  end
  return vmin, vmax
end

function seq.sum(iter, fn)
  local s = 0
  local i = 0
  for v in default_iter(iter) do
    if fn then
      v = fn(v)
    end
    s = s + v
    i = i + 1
  end
  return s, i
end

function seq.copy(iter)
  local res, k = {}, 1
  for v in default_iter(iter) do
    res[k] = v
    k = k + 1
  end
  setmetatable(res, require("common/List"))
  return res
end

function seq.copy2(iter, i1, i2)
  local res, k = {}, 1
  for v1, v2 in iter, i1, i2 do
    res[k] = {v1, v2}
    k = k + 1
  end
  return res
end

function seq.copy_tuples(iter)
  iter = default_iter(iter)
  local res = {}
  local row = {
    iter()
  }
  while 0 < #row do
    tappend(res, row)
    row = {
      iter()
    }
  end
  return res
end

function seq.random(n, l, u)
  local rand
  assert(type(n) == "number")
  if u then
    function rand()
      return mrandom(l, u)
    end
  elseif l then
    function rand()
      return mrandom(l)
    end
  else
    rand = mrandom
  end
  return function()
    if n == 0 then
      return nil
    else
      n = n - 1
      return rand()
    end
  end
end

function seq.sort(iter, comp)
  local t = seq.copy(iter)
  tsort(t, comp)
  return list(t)
end

function seq.zip(iter1, iter2)
  iter1 = default_iter(iter1)
  iter2 = default_iter(iter2)
  return function()
    return iter1(), iter2()
  end
end

function seq.count_map(iter)
  local t = {}
  local v
  for s in default_iter(iter) do
    v = t[s]
    if v then
      t[s] = v + 1
    else
      t[s] = 1
    end
  end
  return setmetatable(t, require("common/Map"))
end

function seq.unique(iter, returns_table)
  local t = seq.count_map(iter)
  local res, k = {}, 1
  for key in pairs(t) do
    res[k] = key
    k = k + 1
  end
  table.sort(res)
  if returns_table then
    return res
  else
    return list(res)
  end
end

function seq.printall(iter, sep, nfields, fmt)
  local write = io.write
  sep = sep or " "
  if not nfields then
    if sep == "\n" then
      nfields = 1.0E30
    else
      nfields = 7
    end
  end
  if fmt then
    local fstr = fmt
    
    function fmt(v)
      return format(fstr, v)
    end
  end
  local k = 1
  for v in default_iter(iter) do
    if fmt then
      v = fmt(v)
    end
    if nfields > k then
      write(v, sep)
      k = k + 1
    else
      write(v, "\n")
      k = 1
    end
  end
  write("\n")
end

function seq.splice(iter1, iter2)
  iter1 = default_iter(iter1)
  iter2 = default_iter(iter2)
  local iter = iter1
  return function()
    local ret = iter()
    if ret == nil then
      if iter == iter1 then
        iter = iter2
        return iter()
      else
        return nil
      end
    else
      return ret
    end
  end
end

function seq.map(fn, iter, arg)
  fn = function_arg(1, fn)
  iter = default_iter(iter)
  return function()
    local v1, v2 = iter()
    if v1 == nil then
      return nil
    end
    return fn(v1, arg or v2) or false
  end
end

function seq.filter(iter, pred, arg)
  pred = function_arg(2, pred)
  return function()
    local v1, v2
    while true do
      v1, v2 = iter()
      if v1 == nil then
        return nil
      end
      if pred(v1, arg or v2) then
        return v1, v2
      end
    end
  end
end

function seq.reduce(fn, iter, initval)
  fn = function_arg(1, fn)
  iter = default_iter(iter)
  local val = initval or iter()
  if val == nil then
    return nil
  end
  for v in iter, nil, nil do
    val = fn(val, v)
  end
  return val
end

function seq.take(iter, n)
  iter = default_iter(iter)
  return function()
    if n < 1 then
      return
    end
    local val1, val2 = iter()
    if not val1 then
      return
    end
    n = n - 1
    return val1, val2
  end
end

function seq.skip(iter, n)
  n = n or 1
  for i = 1, n do
    if iter() == nil then
      return list({})
    end
  end
  return iter
end

function seq.enum(iter)
  local i = 0
  iter = default_iter(iter)
  return function()
    local val1, val2 = iter()
    if not val1 then
      return
    end
    i = i + 1
    return i, val1, val2
  end
end

function seq.mapmethod(iter, name, arg1, arg2)
  iter = default_iter(iter)
  return function()
    local val = iter()
    if not val then
      return
    end
    local fn = val[name]
    if not fn then
      error(type(val) .. " does not have method " .. name)
    end
    return fn(val, arg1, arg2)
  end
end

function seq.last(iter)
  iter = default_iter(iter)
  local val, l = (iter())
  if val == nil then
    return list({})
  end
  return function()
    val, l = iter(), val
    if val == nil then
      return nil
    end
    return val, l
  end
end

function seq.foreach(iter, fn)
  fn = function_arg(2, fn)
  for i1, i2, i3 in default_iter(iter) do
    fn(i1, i2, i3)
  end
end

local SMT

local function SW(iter, ...)
  if callable(iter) then
    return setmetatable({iter = iter}, SMT)
  else
    return iter, ...
  end
end

local map, reduce, mapmethod = seq.map, seq.reduce, seq.mapmethod
local overrides = {
  map = function(self, fun, arg)
    return map(fun, self, arg)
  end,
  reduce = function(self, fun, initval)
    return reduce(fun, self, initval)
  end
}
SMT = {
  __index = function(tbl, key)
    local fn = overrides[key] or seq[key]
    if fn then
      return function(sw, ...)
        return SW(fn(sw.iter, ...))
      end
    else
      return function(sw, ...)
        return SW(mapmethod(sw.iter, key, ...))
      end
    end
  end,
  __call = function(sw)
    return sw.iter()
  end
}
setmetatable(seq, {
  __call = function(tbl, iter, extra)
    if not callable(iter) then
      if type(iter) == "table" then
        iter = seq.list(iter)
      else
        return iter
      end
    end
    if extra then
      return setmetatable({
        iter = function()
          return iter(extra)
        end
      }, SMT)
    else
      return setmetatable({iter = iter}, SMT)
    end
  end
})

function seq.lines(f, ...)
  local iter, obj
  if f == "STDIN" then
    f = io.stdin
  elseif type(f) == "string" then
    iter, obj = io.lines(f, ...)
  elseif not f.read then
    error("Pass either a string or a file-like object", 2)
  end
  if not iter then
    iter, obj = f:lines(...)
  end
  if obj then
    local lines, file = iter, obj
    
    function iter()
      return lines(file)
    end
  end
  return SW(iter)
end

function seq.import()
  debug.setmetatable(function()
  end, {
    __index = function(tbl, key)
      local s = overrides[key] or seq[key]
      if s then
        return s
      else
        return function(s, ...)
          return seq.mapmethod(s, key, ...)
        end
      end
    end
  })
end

return seq
