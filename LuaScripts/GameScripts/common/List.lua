local tinsert, tremove, concat, tsort = table.insert, table.remove, table.concat, table.sort
local setmetatable, getmetatable, type, tostring, string = setmetatable, getmetatable, type, tostring, _ENV.string
local tablex = require("common/tablex")
local filter, imap, imap2, reduce, transform, tremovevalues = table.filter, table.imap, table.imap2, table.reduce, table.transform, table.removevalues
local tsub = table.sub
local utils = require("common/utils")
local class = require("common/class")
local array_tostring, split, assert_arg, function_arg = utils.array_tostring, utils.split, utils.assert_arg, utils.function_arg
local normalize_slice = table._normalize_slice
local Multimap = utils.stdmt.MultiMap
local List = utils.stdmt.List
local iter
class(nil, nil, List)

local function makelist(t, obj)
  local klass = List
  if obj then
    klass = getmetatable(obj)
  end
  return setmetatable(t, klass)
end

local function simple_table(t)
  return type(t) == "table" and not getmetatable(t) and 0 < #t
end

function List._create(src)
  if simple_table(src) then
    return src
  end
end

function List:_init(src)
  if self == src then
    return
  end
  if src then
    for v in iter(src) do
      tinsert(self, v)
    end
  end
end

List.new = List

function List:clone()
  local ls = makelist({}, self)
  ls:extend(self)
  return ls
end

function List:append(i)
  tinsert(self, i)
  return self
end

List.push = tinsert

function List:extend(L)
  assert_arg(1, L, "table")
  for i = 1, #L do
    tinsert(self, L[i])
  end
  return self
end

function List:insert(i, x)
  assert_arg(1, i, "number")
  tinsert(self, i, x)
  return self
end

function List:put(x)
  return self:insert(1, x)
end

function List:remove(i)
  assert_arg(1, i, "number")
  tremove(self, i)
  return self
end

function List:remove_value(x)
  for i = 1, #self do
    if self[i] == x then
      tremove(self, i)
      return self
    end
  end
  return self
end

function List:pop(i)
  i = i or #self
  assert_arg(1, i, "number")
  return tremove(self, i)
end

List.get = List.pop
local tfind = table.find
List.index = tfind

function List:contains(x)
  return tfind(self, x) and true or false
end

function List:count(x)
  local cnt = 0
  for i = 1, #self do
    if self[i] == x then
      cnt = cnt + 1
    end
  end
  return cnt
end

function List:sort(cmp)
  cmp = cmp and function_arg(1, cmp)
  tsort(self, cmp)
  return self
end

function List:sorted(cmp)
  return List(self):sort(cmp)
end

function List:reverse()
  local t = self
  local n = #t
  for i = 1, n / 2 do
    t[i], t[n] = t[n], t[i]
    n = n - 1
  end
  return self
end

function List:minmax()
  local vmin, vmax = 1.0E70, -1.0E70
  for i = 1, #self do
    local v = self[i]
    if vmin > v then
      vmin = v
    end
    if vmax < v then
      vmax = v
    end
  end
  return vmin, vmax
end

function List:slice(first, last)
  return tsub(self, first, last)
end

function List:clear()
  for i = 1, #self do
    tremove(self)
  end
  return self
end

local eps = 1.0E-10

function List.range(start, finish, incr)
  if not finish then
    finish = start
    start = 1
  end
  if incr then
    assert_arg(3, incr, "number")
    if math.ceil(incr) ~= incr then
      finish = finish + eps
    end
  else
    incr = 1
  end
  assert_arg(1, start, "number")
  assert_arg(2, finish, "number")
  local t = List()
  for i = start, finish, incr do
    tinsert(t, i)
  end
  return t
end

function List:len()
  return #self
end

function List:chop(i1, i2)
  return tremovevalues(self, i1, i2)
end

function List:splice(idx, list)
  assert_arg(1, idx, "number")
  idx = idx - 1
  local i = 1
  for v in iter(list) do
    tinsert(self, i + idx, v)
    i = i + 1
  end
  return self
end

function List:slice_assign(i1, i2, seq)
  assert_arg(1, i1, "number")
  assert_arg(1, i2, "number")
  i1, i2 = normalize_slice(self, i1, i2)
  if i1 <= i2 then
    self:chop(i1, i2)
  end
  self:splice(i1, seq)
  return self
end

function List:__concat(L)
  assert_arg(1, L, "table")
  local ls = self:clone()
  ls:extend(L)
  return ls
end

function List:__eq(L)
  if #self ~= #L then
    return false
  end
  for i = 1, #self do
    if self[i] ~= L[i] then
      return false
    end
  end
  return true
end

function List:join(delim)
  delim = delim or ""
  assert_arg(1, delim, "string")
  return concat(array_tostring(self), delim)
end

List.concat = concat

local function tostring_q(val)
  local s = tostring(val)
  if type(val) == "string" then
    s = "\"" .. s .. "\""
  end
  return s
end

function List:__tostring()
  return "{" .. self:join(",", tostring_q) .. "}"
end

function List:foreach(fun, ...)
  fun = function_arg(1, fun)
  for i = 1, #self do
    fun(self[i], ...)
  end
end

local function lookup_fun(obj, name)
  local f = obj[name]
  if not f then
    error(type(obj) .. " does not have method " .. name, 3)
  end
  return f
end

function List:foreachm(name, ...)
  for i = 1, #self do
    local obj = self[i]
    local f = lookup_fun(obj, name)
    f(obj, ...)
  end
end

function List:filter(fun, arg)
  return makelist(filter(self, fun, arg), self)
end

function List.split(s, delim)
  assert_arg(1, s, "string")
  return makelist(split(s, delim))
end

function List:map(fun, ...)
  return makelist(imap(fun, self, ...), self)
end

function List:transform(fun, ...)
  transform(fun, self, ...)
  return self
end

function List:map2(fun, ls, ...)
  return makelist(imap2(fun, self, ls, ...), self)
end

function List:mapm(name, ...)
  local res = {}
  for i = 1, #self do
    local val = self[i]
    local fn = lookup_fun(val, name)
    res[i] = fn(val, ...)
  end
  return makelist(res, self)
end

local function composite_call(method, f)
  return function(self, ...)
    return self[method](self, f, ...)
  end
end

function List.default_map_with(T)
  return function(self, name)
    local m
    if T then
      local f = lookup_fun(T, name)
      m = composite_call("map", f)
    else
      m = composite_call("mapn", name)
    end
    getmetatable(self)[name] = m
    return m
  end
end

List.default_map = List.default_map_with

function List:reduce(fun)
  return reduce(fun, self)
end

function List:partition(fun, ...)
  fun = function_arg(1, fun)
  local res = {}
  for i = 1, #self do
    local val = self[i]
    local klass = fun(val, ...)
    if klass == nil then
      klass = "<nil>"
    end
    if not res[klass] then
      res[klass] = List()
    end
    res[klass]:append(val)
  end
  return setmetatable(res, Multimap)
end

function List:iter()
  return iter(self)
end

function List.iterate(seq)
  if type(seq) == "string" then
    local idx = 0
    local n = #seq
    local sub = string.sub
    return function()
      idx = idx + 1
      if idx > n then
        return nil
      else
        return sub(seq, idx, idx)
      end
    end
  elseif type(seq) == "table" then
    local idx = 0
    local n = #seq
    return function()
      idx = idx + 1
      if idx > n then
        return nil
      else
        return seq[idx]
      end
    end
  elseif type(seq) == "function" then
    return seq
  elseif type(seq) == "userdata" and io.type(seq) == "file" then
    return seq:lines()
  end
end

iter = List.iterate
return List
