function setmetatableindex(t, index)
  if type(t) == "userdata" then
    for k, v in pairs(index) do
      t[k] = v
    end
  else
    local mt = getmetatable(t)
    mt = mt or {}
    if not mt.__index then
      mt.__index = index
      setmetatable(t, mt)
    elseif mt.__index ~= index then
      setmetatableindex(mt, index)
    end
  end
end

local type = _ENV.type
local pairs = _ENV.pairs
local setmetatable = _ENV.setmetatable
local classTypeId = 1000
local instanceId = 20000

function class(classname, ...)
  local cls = {__cname = classname}
  local supers = {
    ...
  }
  local clsIndex = {}
  for _, super in ipairs(supers) do
    local superType = type(super)
    assert(superType == "nil" or superType == "table" or superType == "function", string.format("class() - create class \"%s\" with invalid super class type \"%s\"", classname, superType))
    if superType == "function" then
      assert(cls.__create == nil, string.format("class() - create class \"%s\" with more than one creating function", classname))
      cls.__create = super
    elseif superType == "table" then
      if super[".isclass"] then
        assert(cls.__create == nil, string.format("class() - create class \"%s\" with more than one creating function or native class", classname))
        
        function cls.__create()
          return super:create()
        end
      else
        cls.__supers = cls.__supers or {}
        cls.__supers[#cls.__supers + 1] = super
        if not cls.super then
          cls.super = super
        end
      end
    else
      log.error(string.format("class() - create class \"%s\" with invalid super type", classname), 0)
    end
  end
  cls.__classTypeId = classTypeId
  classTypeId = classTypeId + 1
  if not cls.__supers or #cls.__supers == 1 then
    setmetatable(cls, {
      __index = cls.super
    })
  else
    setmetatable(cls, {
      __index = function(_, key)
        local supers = cls.__supers
        for i = 1, #supers do
          local super = supers[i]
          if super[key] then
            return super[key]
          end
        end
      end
    })
  end
  if not cls.ctor then
    function cls.ctor()
    end
  end
  if not rawget(cls, "getName") then
    function cls.getName()
      return cls.__cname
    end
  end
  
  function cls.new(...)
    local instance
    if cls.__create then
      instance = cls.__create(...)
    else
      instance = {}
    end
    setmetatableindex(instance, cls)
    instance.class = cls
    instance:ctor(...)
    instanceId = instanceId + 1
    instance.____instanceId = instanceId
    return instance
  end
  
  function cls.create(_, ...)
    return cls.new(...)
  end
  
  return cls
end

local error, getmetatable, io, pairs, rawget, rawset, setmetatable, tostring, type = _G.error, _G.getmetatable, _G.io, _G.pairs, _G.rawget, _G.rawset, _G.setmetatable, _G.tostring, _G.type
local compat

local function call_ctor(c, obj, ...)
  local init = rawget(c, "_init")
  local parent_with_init = rawget(c, "_parent_with_init")
  if parent_with_init then
    if not init then
      init = rawget(parent_with_init, "_init")
      parent_with_init = rawget(parent_with_init, "_parent_with_init")
    end
    if parent_with_init then
      rawset(obj, "super", function(obj, ...)
        call_ctor(parent_with_init, obj, ...)
      end)
    end
  else
    rawset(obj, "super", nil)
  end
  local res = init(obj, ...)
  if parent_with_init then
    rawset(obj, "super", nil)
  end
  return res
end

local function is_a(self, klass)
  if klass == nil then
    return getmetatable(self)
  end
  local m = getmetatable(self)
  if not m then
    return false
  end
  while m do
    if m == klass then
      return true
    end
    m = rawget(m, "_base")
  end
  return false
end

local function class_of(klass, obj)
  if type(klass) ~= "table" or not rawget(klass, "is_a") then
    return false
  end
  return klass.is_a(obj, klass)
end

local function cast(klass, obj)
  return setmetatable(obj, klass)
end

local function _class_tostring(obj)
  local mt = obj._class
  local name = rawget(mt, "_name")
  setmetatable(obj, nil)
  local str = tostring(obj)
  setmetatable(obj, mt)
  if name then
    str = name .. str:gsub("table", "")
  end
  return str
end

local function tupdate(td, ts, dont_override)
  for k, v in pairs(ts) do
    if not dont_override or td[k] == nil then
      td[k] = v
    end
  end
end

local function _class(base, c_arg, c)
  local mt = {}
  local plain = type(base) == "table" and not getmetatable(base)
  if plain then
    c = base
    base = c._base
  else
    c = c or {}
  end
  if type(base) == "table" then
    tupdate(c, base, plain)
    c._base = base
    if rawget(c, "_handler") then
      mt.__index = c._handler
    end
  elseif base ~= nil then
    error("must derive from a table type", 3)
  end
  c.__index = c
  setmetatable(c, mt)
  if not plain then
    if base and rawget(base, "_init") then
      c._parent_with_init = base
    end
    c._init = nil
  end
  if base and rawget(base, "_class_init") then
    base._class_init(c, c_arg)
  end
  
  function mt.__call(class_tbl, ...)
    local obj
    if rawget(c, "_create") then
      obj = c._create(...)
    end
    obj = obj or {}
    setmetatable(obj, c)
    if rawget(c, "_init") or rawget(c, "_parent_with_init") then
      local res = call_ctor(c, obj, ...)
      if res then
        obj = res
        setmetatable(obj, c)
      end
    end
    if base and rawget(base, "_post_init") then
      base._post_init(obj)
    end
    return obj
  end
  
  function c:catch(handler)
    if type(self) == "function" then
      handler = self
    end
    c._handler = handler
    mt.__index = handler
  end
  
  c.is_a = is_a
  c.class_of = class_of
  c.cast = cast
  c._class = c
  if not rawget(c, "__tostring") then
    c.__tostring = _class_tostring
  end
  return c
end

local class
class = setmetatable({}, {
  __call = function(fun, ...)
    return _class(...)
  end,
  __index = function(tbl, key)
    if key == "class" then
      io.stderr:write("require(\"pl/class\").class is deprecated. Use require(\"pl/class\")\n")
      return class
    end
    compat = compat or require("common/compat")
    local env = compat.getfenv(2)
    return function(...)
      local c = _class(...)
      c._name = key
      rawset(env, key, c)
      return c
    end
  end
})
class.properties = class()

function class.properties._class_init(klass)
  function klass.__index(t, key)
    local v = klass[key]
    
    if v then
      return v
    end
    v = rawget(klass, "get_" .. key)
    if v then
      return v(t)
    end
    return rawget(t, "_" .. key)
  end
  
  function klass.__newindex(t, key, value)
    local p = "set_" .. key
    local setter = klass[p]
    if setter then
      setter(t, value)
    else
      rawset(t, key, value)
    end
  end
end

return class
