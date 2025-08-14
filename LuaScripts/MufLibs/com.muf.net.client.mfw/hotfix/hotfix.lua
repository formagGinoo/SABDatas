local hotfix_table = {}

local function hotfix_one(cs_type, funcName, func)
  xlua.hotfix(cs_type, funcName, func)
  local prefixed = hotfix_table[cs_type]
  if not prefixed then
    prefixed = {}
    hotfix_table[cs_type] = prefixed
  end
  prefixed[funcName] = true
end

local function hotfix_all(cs_type, funcTables)
  for k, v in pairs(funcTables) do
    hotfix_one(cs_type, k, v)
  end
end

local function hotfix(cs_type, arg1, arg2)
  local arg1Type = type(arg1)
  if arg1Type == "string" then
    hotfix_one(cs_type, arg1, arg2)
  elseif arg1Type == "table" then
    hotfix_all(cs_type, arg1)
  end
end

local function unregisterHotfix()
  for k, v in pairs(hotfix_table) do
    for k1, v1 in pairs(v) do
      xlua.hotfix(k, k1, nil)
    end
  end
end

CS.LuaManager.Instance.funcUnregisterHotFix = unregisterHotfix
return hotfix
