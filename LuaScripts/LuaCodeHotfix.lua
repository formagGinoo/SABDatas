function OnLuaCodeRepair(luaTableValue)
  LuaRepairTable.m_iGetLuaRepairTime = os.time()
  
  if nil == luaTableValue then
    return
  end
  if LuaRepairTable.luaTableValue == nil then
    LuaRepairTable.luaTableValue = {}
  end
  for k, v in pairs(luaTableValue) do
    LuaRepairTable.luaTableValue[k] = v
  end
  for k, v in pairs(luaTableValue) do
    if string.isnullorempty(k) or is_required(k) then
      log.info("OnLuaCodeRepair : " .. v)
      pcall(load(v))
    end
  end
end

function RequestLuaCodeStatus(fCB)
  local iCurTime = os.time()
  if iCurTime - LuaRepairTable.m_iGetLuaRepairTime < 600 then
    if fCB then
      fCB(0)
    end
    return
  end
  LuaRepairTable.m_iGetLuaRepairTime = iCurTime
  local reqMsg = MTTDProto.Cmd_Role_GetLuaRepair_CS()
  reqMsg.iCurMaxRepairID = LuaRepairTable.m_iMaxLuaCodeRepairID
  RPCS():Role_GetLuaRepair(reqMsg, function(sc, msg)
    local iSeverityMax = 0
    for iReqairID, iSeverity in pairs(sc.mLuaIDSeverity) do
      if iReqairID > LuaRepairTable.m_iMaxLuaCodeRepairID then
        LuaRepairTable.m_iMaxLuaCodeRepairID = iReqairID
      end
      if iSeverity > iSeverityMax then
        iSeverityMax = iSeverity
      end
    end
    if fCB then
      fCB(iSeverityMax)
    end
  end)
end
