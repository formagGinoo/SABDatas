local compat = {}
compat.lua51 = _VERSION == "Lua 5.1"
compat.jit = tostring(assert):match("builtin") ~= nil
if compat.jit then
  compat.jit52 = not loadstring("local goto = 1")
end
compat.dir_separator = _G.package.config:sub(1, 1)
compat.is_windows = compat.dir_separator == "\\"

function compat.execute(cmd)
  local res1, res2, res3 = os.execute(cmd)
  if res2 == "No error" and res3 == 0 and compat.is_windows then
    res3 = -1
  end
  if compat.lua51 and not compat.jit52 then
    if compat.is_windows then
      return res1 == 0, res1
    else
      res1 = 255 < res1 and res1 / 256 or res1
      return res1 == 0, res1
    end
  elseif compat.is_windows then
    return res3 == 0, res3
  else
    return not not res1, res3
  end
end

if compat.lua51 then
  if not compat.jit then
    local lua51_load = load
    
    function compat.load(str, src, mode, env)
      local chunk, err
      if type(str) == "string" then
        if str:byte(1) == 27 and not (mode or "bt"):find("b") then
          return nil, "attempt to load a binary chunk"
        end
        chunk, err = loadstring(str, src)
      else
        chunk, err = lua51_load(str, src)
      end
      if chunk and env then
        setfenv(chunk, env)
      end
      return chunk, err
    end
  else
    compat.load = load
  end
  compat.setfenv, compat.getfenv = setfenv, getfenv
else
  compat.load = load
  
  function compat.setfenv(f, t)
    f = type(f) == "function" and f or debug.getinfo(f + 1, "f").func
    local name
    local up = 0
    repeat
      up = up + 1
      name = debug.getupvalue(f, up)
    until name == "_ENV" or name == nil
    if name then
      debug.upvaluejoin(f, up, function()
        return name
      end, 1)
      debug.setupvalue(f, up, t)
    end
    if f ~= 0 then
      return f
    end
  end
  
  function compat.getfenv(f)
    local f = f or 0
    f = type(f) == "function" and f or debug.getinfo(f + 1, "f").func
    local name, val
    local up = 0
    repeat
      up = up + 1
      name, val = debug.getupvalue(f, up)
    until name == "_ENV" or name == nil
    return val
  end
end
if not table.pack then
  function table.pack(...)
    return {
      n = select("#", ...),
      
      ...
    }
  end
end
if not table.unpack then
  table.unpack = unpack
end
if not package.searchpath then
  function package.searchpath(name, path, sep, rep)
    if type(name) ~= "string" then
      error(("bad argument #1 to 'searchpath' (string expected, got %s)"):format(type(path)), 2)
    end
    if type(path) ~= "string" then
      error(("bad argument #2 to 'searchpath' (string expected, got %s)"):format(type(path)), 2)
    end
    if sep ~= nil and type(sep) ~= "string" then
      error(("bad argument #3 to 'searchpath' (string expected, got %s)"):format(type(path)), 2)
    end
    if rep ~= nil and type(rep) ~= "string" then
      error(("bad argument #4 to 'searchpath' (string expected, got %s)"):format(type(path)), 2)
    end
    sep = sep or "."
    rep = rep or compat.dir_separator
    do
      local s, e = name:find(sep, nil, true)
      while s do
        name = name:sub(1, s - 1) .. rep .. name:sub(e + 1, -1)
        s, e = name:find(sep, s + #rep + 1, true)
      end
    end
    local tried = {}
    for m in path:gmatch("[^;]+") do
      local nm = m:gsub("?", name)
      tried[#tried + 1] = nm
      local f = io.open(nm, "r")
      if f then
        f:close()
        return nm
      end
    end
    return nil, "\tno file '" .. table.concat(tried, [[
'
	no file ']]) .. "'"
  end
end
if not warn then
  local enabled = false
  
  local function warn(arg1, ...)
    if type(arg1) == "string" and arg1:sub(1, 1) == "@" then
      if arg1 == "@on" then
        enabled = true
        return
      end
      if arg1 == "@off" then
        enabled = false
        return
      end
      return
    end
    if enabled then
      io.stderr:write("Lua warning: ", arg1, ...)
      io.stderr:write("\n")
    end
  end
  
  rawset(_G, "warn", warn)
end
return compat
