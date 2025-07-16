local _G = _ENV._G
local sub = string.sub
local getenv = os.getenv
local tmpnam = os.tmpname
local package = _ENV.package
local append, concat, remove = table.insert, table.concat, table.remove
local utils = require("common/utils")
local assert_string, raise = utils.assert_string, utils.raise
local res, lfs = _G.pcall(_G.require, "lfs")
if not res then
  error("pl/path requires LuaFileSystem")
end
local attrib = lfs.attributes
local currentdir = lfs.currentdir
local link_attrib = lfs.symlinkattributes
local path = {}

local function err_func(name, param, err, code)
  local ret = ("%s failed"):format(tostring(name))
  if param ~= nil then
    ret = ret .. (" for '%s'"):format(tostring(param))
  end
  ret = ret .. (": %s"):format(tostring(err))
  if code ~= nil then
    ret = ret .. (" (code %s)"):format(tostring(code))
  end
  return ret
end

path.dir = lfs.dir

function path.mkdir(d)
  local ok, err, code = lfs.mkdir(d)
  if not ok then
    return ok, err_func("mkdir", d, err, code), code
  end
  return ok, err, code
end

function path.rmdir(d)
  local ok, err, code = lfs.rmdir(d)
  if not ok then
    return ok, err_func("rmdir", d, err, code), code
  end
  return ok, err, code
end

function path.attrib(d, r)
  local ok, err, code = attrib(d, r)
  if not ok then
    return ok, err_func("attrib", d, err, code), code
  end
  return ok, err, code
end

function path.currentdir()
  local ok, err, code = currentdir()
  if not ok then
    return ok, err_func("currentdir", nil, err, code), code
  end
  return ok, err, code
end

function path.link_attrib(d, r)
  local ok, err, code = link_attrib(d, r)
  if not ok then
    return ok, err_func("link_attrib", d, err, code), code
  end
  return ok, err, code
end

function path.chdir(d)
  local ok, err, code = lfs.chdir(d)
  if not ok then
    return ok, err_func("chdir", d, err, code), code
  end
  return ok, err, code
end

function path.isdir(P)
  assert_string(1, P)
  if P:match("\\$") then
    P = P:sub(1, -2)
  end
  return attrib(P, "mode") == "directory"
end

function path.isfile(P)
  assert_string(1, P)
  return attrib(P, "mode") == "file"
end

function path.islink(P)
  assert_string(1, P)
  if link_attrib then
    return link_attrib(P, "mode") == "link"
  else
    return false
  end
end

function path.getsize(P)
  assert_string(1, P)
  return attrib(P, "size")
end

function path.exists(P)
  assert_string(1, P)
  return attrib(P, "mode") ~= nil and P
end

function path.getatime(P)
  assert_string(1, P)
  return attrib(P, "access")
end

function path.getmtime(P)
  assert_string(1, P)
  return attrib(P, "modification")
end

function path.getctime(P)
  assert_string(1, P)
  return path.attrib(P, "change")
end

local function at(s, i)
  return sub(s, i, i)
end

path.is_windows = utils.is_windows
local sep, other_sep, seps
if path.is_windows then
  path.sep = "\\"
  other_sep = "/"
  path.dirsep = ";"
  seps = {
    ["/"] = true,
    ["\\"] = true
  }
else
  path.sep = "/"
  path.dirsep = ":"
  seps = {
    ["/"] = true
  }
end
sep = path.sep

function path.splitpath(P)
  assert_string(1, P)
  local i = #P
  local ch = at(P, i)
  while 0 < i and ch ~= sep and ch ~= other_sep do
    i = i - 1
    ch = at(P, i)
  end
  if i == 0 then
    return "", P
  else
    return sub(P, 1, i - 1), sub(P, i + 1)
  end
end

function path.abspath(P, pwd)
  assert_string(1, P)
  if pwd then
    assert_string(2, pwd)
  end
  local use_pwd = pwd ~= nil
  if not use_pwd and not currentdir() then
    return P
  end
  P = P:gsub("[\\/]$", "")
  pwd = pwd or currentdir()
  if not path.isabs(P) then
    P = path.join(pwd, P)
  elseif path.is_windows and not use_pwd and at(P, 2) ~= ":" and at(P, 2) ~= "\\" then
    P = pwd:sub(1, 2) .. P
  end
  return path.normpath(P)
end

function path.splitext(P)
  assert_string(1, P)
  local i = #P
  local ch = at(P, i)
  while 0 < i and ch ~= "." do
    if seps[ch] then
      return P, ""
    end
    i = i - 1
    ch = at(P, i)
  end
  if i == 0 then
    return P, ""
  else
    return sub(P, 1, i - 1), sub(P, i)
  end
end

function path.dirname(P)
  assert_string(1, P)
  local p1 = path.splitpath(P)
  return p1
end

function path.basename(P)
  assert_string(1, P)
  local _, p2 = path.splitpath(P)
  return p2
end

function path.extension(P)
  assert_string(1, P)
  local _, p2 = path.splitext(P)
  return p2
end

function path.isabs(P)
  assert_string(1, P)
  if path.is_windows and at(P, 2) == ":" then
    return seps[at(P, 3)] ~= nil
  end
  return seps[at(P, 1)] ~= nil
end

function path.join(p1, p2, ...)
  assert_string(1, p1)
  assert_string(2, p2)
  if select("#", ...) > 0 then
    local p = path.join(p1, p2)
    local args = {
      ...
    }
    for i = 1, #args do
      assert_string(i, args[i])
      p = path.join(p, args[i])
    end
    return p
  end
  if path.isabs(p2) then
    return p2
  end
  local endc = at(p1, #p1)
  if endc ~= path.sep and endc ~= other_sep and endc ~= "" then
    p1 = p1 .. path.sep
  end
  return p1 .. p2
end

function path.normcase(P)
  assert_string(1, P)
  if path.is_windows then
    return P:gsub("/", "\\"):lower()
  else
    return P
  end
end

function path.normpath(P)
  assert_string(1, P)
  local anchor = ""
  if path.is_windows then
    if P:match("^\\\\") then
      anchor = "\\\\"
      P = P:sub(3)
    elseif seps[at(P, 1)] then
      anchor = "\\"
      P = P:sub(2)
    elseif at(P, 2) == ":" then
      anchor = P:sub(1, 2)
      P = P:sub(3)
      if seps[at(P, 1)] then
        anchor = anchor .. "\\"
        P = P:sub(2)
      end
    end
    P = P:gsub("/", "\\")
  elseif P:match("^//") and at(P, 3) ~= "/" then
    anchor = "//"
    P = P:sub(3)
  elseif at(P, 1) == "/" then
    anchor = "/"
    P = P:match("^/*(.*)$")
  end
  local parts = {}
  for part in P:gmatch("[^" .. sep .. "]+") do
    if part == ".." then
      if #parts ~= 0 and parts[#parts] ~= ".." then
        remove(parts)
      else
        append(parts, part)
      end
    elseif part ~= "." then
      append(parts, part)
    end
  end
  P = anchor .. concat(parts, sep)
  if P == "" then
    P = "."
  end
  return P
end

function path.relpath(P, start)
  assert_string(1, P)
  if start then
    assert_string(2, start)
  end
  local split, min, append = utils.split, math.min, table.insert
  P = path.abspath(P, start)
  start = start or currentdir()
  local compare
  if path.is_windows then
    P = P:gsub("/", "\\")
    start = start:gsub("/", "\\")
    
    function compare(v)
      return v:lower()
    end
  else
    function compare(v)
      return v
    end
  end
  local startl, Pl = split(start, sep), split(P, sep)
  local n = min(#startl, #Pl)
  if path.is_windows and 0 < n and at(Pl[1], 2) == ":" and Pl[1] ~= startl[1] then
    return P
  end
  local k = n + 1
  for i = 1, n do
    if compare(startl[i]) ~= compare(Pl[i]) then
      k = i
      break
    end
  end
  local rell = {}
  for i = 1, #startl - k + 1 do
    rell[i] = ".."
  end
  if k <= #Pl then
    for i = k, #Pl do
      append(rell, Pl[i])
    end
  end
  return table.concat(rell, sep)
end

function path.expanduser(P)
  assert_string(1, P)
  if at(P, 1) == "~" then
    local home = getenv("HOME")
    home = home or getenv("USERPROFILE") or getenv("HOMEDRIVE") .. getenv("HOMEPATH")
    return home .. sub(P, 2)
  else
    return P
  end
end

function path.tmpname()
  local res = tmpnam()
  if path.is_windows and not res:find(":") then
    res = getenv("TEMP") .. res
  end
  return res
end

function path.common_prefix(path1, path2)
  assert_string(1, path1)
  assert_string(2, path2)
  if #path1 > #path2 then
    path2, path1 = path1, path2
  end
  local compare
  if path.is_windows then
    path1 = path1:gsub("/", "\\")
    path2 = path2:gsub("/", "\\")
    
    function compare(v)
      return v:lower()
    end
  else
    function compare(v)
      return v
    end
  end
  for i = 1, #path1 do
    if compare(at(path1, i)) ~= compare(at(path2, i)) then
      local cp = path1:sub(1, i - 1)
      if at(path1, i - 1) ~= sep then
        cp = path.dirname(cp)
      end
      return cp
    end
  end
  if at(path2, #path1 + 1) ~= sep then
    path1 = path.dirname(path1)
  end
  return path1
end

function path.package_path(mod)
  assert_string(1, mod)
  local res, err1, err2
  res, err1 = package.searchpath(mod, package.path)
  if res then
    return res, true
  end
  res, err2 = package.searchpath(mod, package.cpath)
  if res then
    return res, false
  end
  return raise("cannot find module on path\n" .. err1 .. "\n" .. err2)
end

return path
