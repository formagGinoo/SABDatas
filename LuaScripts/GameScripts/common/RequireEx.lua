local oldRequire = require
local luaFileTables = {}
LuaRepairTable = LuaRepairTable or {}
LuaRepairTable.m_sCurrentRairLua = nil
LuaRepairTable.m_iMaxLuaCodeRepairID = 0
LuaRepairTable.m_iGetLuaRepairTime = 0
local bAdjustSandBox = false

function LuaReload(moduleName)
  package.loaded[moduleName] = nil
  return require(moduleName)
end

function CustomRequire(moduleName)
  if LUA_RELOAD_DEBUG and CS.UnityEngine.Application.isEditor then
    return LuaReload(moduleName)
  else
    return require(moduleName)
  end
end

function require(luaFileName)
  if bAdjustSandBox then
    print(luaFileName)
  end
  local luaFile = package.loaded[luaFileName]
  if luaFile ~= nil then
    return luaFile
  end
  luaFile = package.preload[luaFileName]
  if luaFile ~= nil then
    return luaFile
  end
  table.insert(luaFileTables, luaFileName)
  local ret = oldRequire(luaFileName)
  if nil ~= LuaRepairTable.luaTableValue and LuaRepairTable.m_sCurrentRairLua ~= luaFileName then
    local hotFix = LuaRepairTable.luaTableValue[luaFileName]
    if nil ~= hotFix then
      pcall(load(hotFix))
    end
  end
  return ret
end

function unrequire(luaFileName)
  if nil == luaFileName then
    return
  end
  package.loaded[luaFileName] = nil
  package.preload[luaFileName] = nil
end

function is_required(luaFileName)
  return package.loaded[luaFileName] ~= nil
end

function LuaRepairTable.repairLua()
  for file, v in pairs(LuaRepairTable.luaTableValue) do
    local hotFix = LuaRepairTable.luaTableValue[file]
    if nil ~= hotFix then
      LuaRepairTable.m_sCurrentRairLua = file
      pcall(load(hotFix))
      LuaRepairTable.m_sCurrentRairLua = nil
    end
  end
end

function LuaRepairTable.repairBattleLua(repairCode)
  LuaRepairTable.luaTableValue = repairCode
  for file, v in pairs(LuaRepairTable.luaTableValue) do
    local hotFix = LuaRepairTable.luaTableValue[file]
    if nil ~= hotFix then
      LuaRepairTable.m_sCurrentRairLua = file
      pcall(load(hotFix))
      LuaRepairTable.m_sCurrentRairLua = nil
    end
  end
end

function UnLoadAllLuaFile()
  for k, v in ipairs(luaFileTables) do
    package.loaded[v] = nil
    package.preload[v] = nil
  end
  package.loaded["common/RequireEx"] = nil
  package.preload["common/RequireEx"] = nil
  luaFileTables = {}
  require = oldRequire
end
