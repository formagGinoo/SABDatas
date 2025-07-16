local utils = require("common/utils")
local math_ceil = math.ceil
local assert_arg = utils.assert_arg
local types = {}

function types.is_callable(obj)
  return type(obj) == "function" or getmetatable(obj) and getmetatable(obj).__call and true
end

types.is_type = utils.is_type
local fileMT = getmetatable(io.stdout)

function types.type(obj)
  local t = type(obj)
  if t == "table" or t == "userdata" then
    local mt = getmetatable(obj)
    if mt == fileMT then
      return "file"
    elseif mt == nil then
      return t
    else
      return mt._name or "unknown " .. t
    end
  else
    return t
  end
end

function types.is_integer(x)
  return math_ceil(x) == x
end

function types.is_empty(o, ignore_spaces)
  if o == nil then
    return true
  elseif type(o) == "table" then
    return next(o) == nil
  elseif type(o) == "string" then
    return o == "" or not not ignore_spaces and not not o:find("^%s+$")
  else
    return true
  end
end

local function check_meta(val)
  if type(val) == "table" then
    return true
  end
  return getmetatable(val)
end

function types.is_indexable(val)
  local mt = check_meta(val)
  if mt == true then
    return true
  end
  return mt and mt.__len and mt.__index and true
end

function types.is_iterable(val)
  local mt = check_meta(val)
  if mt == true then
    return true
  end
  return mt and mt.__pairs and true
end

function types.is_writeable(val)
  local mt = check_meta(val)
  if mt == true then
    return true
  end
  return mt and mt.__newindex and true
end

local trues = {
  yes = true,
  y = true,
  ["true"] = true,
  t = true,
  ["1"] = true
}
local true_types = {
  boolean = function(o, true_strs, check_objs)
    return o
  end,
  string = function(o, true_strs, check_objs)
    o = o:lower()
    if trues[o] then
      return true
    end
    for _, v in ipairs(true_strs or {}) do
      if type(v) == "string" and o == v:lower() then
        return true
      end
    end
    return false
  end,
  number = function(o, true_strs, check_objs)
    return o ~= 0
  end,
  table = function(o, true_strs, check_objs)
    if check_objs and next(o) ~= nil then
      return true
    end
    return false
  end
}

function types.to_bool(o, true_strs, check_objs)
  local true_func
  if true_strs then
    assert_arg(2, true_strs, "table")
  end
  true_func = true_types[type(o)]
  if true_func then
    return true_func(o, true_strs, check_objs)
  elseif check_objs and o ~= nil then
    return true
  end
  return false
end

function types.check_bool(value)
  return value ~= nil and value ~= false
end

function types.is_set(hashtable, key)
  local t = type(hashtable)
  return (t == "table" or t == "userdata") and hashtable[key] ~= nil
end

function types.is_kindof(obj, classname)
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

return types
