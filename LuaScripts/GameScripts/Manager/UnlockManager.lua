local BaseManager = require("Manager/Base/BaseManager")
local UnlockManager = class("UnlockManager", BaseManager)

function UnlockManager:OnCreate()
  self.m_systemIdList = {}
  self.m_popupUnlockSystemIdList = {}
  self.m_clientData = ""
end

function UnlockManager:OnInitNetwork()
  RPCS():Listen_Push_SystemOpen(handler(self, self.OnPushUnlock), "UnlockManager")
end

function UnlockManager:OnInitMustRequestInFetchMore()
  self.m_clientData = ClientDataManager:GetClientValueStringByKey(MTTDProto.CmdClientDataType_Unlock) or ""
end

function UnlockManager:OnPushUnlock(stData, msg)
  self.m_systemIdList = stData.vSystemId
  local popSystemList = {}
  local unPopSystemList = {}
  for i, systemId in pairs(self.m_systemIdList) do
    local cfg = UnlockSystemUtil:GetSystemUnlockConfig(systemId)
    if cfg and cfg.m_UnlockType == 1 then
      popSystemList[#popSystemList + 1] = systemId
    elseif cfg and cfg.m_UnlockType ~= 1 then
      unPopSystemList[#unPopSystemList + 1] = systemId
    end
  end
  if 0 < #popSystemList then
    self:broadcastEvent("eGameEvent_PopupUnlockSystem", popSystemList)
  end
  if 0 < #unPopSystemList then
    self:broadcastEvent("eGameEvent_UnlockSystem", unPopSystemList)
  end
end

function UnlockManager:ReqSetClientData(id)
  local clientDataCSMsg = MTTDProto.Cmd_ClientData_SetData_CS()
  if self:ClientDataIsHaveSameString(self.m_clientData, id) then
    log.error("UnlockManager Repeat unlock id == " .. id)
    return
  end
  if self.m_clientData ~= "" then
    self.m_clientData = self.m_clientData .. "," .. id
  else
    self.m_clientData = tostring(id)
  end
  local clientData = {
    iExpireTime = 0,
    iActId = 0,
    sClientData = self.m_clientData
  }
  clientDataCSMsg.mData[MTTDProto.CmdClientDataType_Unlock] = clientData
  RPCS():ClientData_SetData(clientDataCSMsg, handler(self, self.OnSetClientDataSC))
end

function UnlockManager:ClientDataIsHaveSameString(str, id)
  if str == nil or str == "" then
    return
  end
  for num in string.gmatch(str, "%d+") do
    if tonumber(num) == id then
      return true
    end
  end
end

function UnlockManager:OnSetClientDataSC(clientData, msg)
  log.info("UnlockManager OnSetClientDataSC afkData: ", tostring(clientData))
end

function UnlockManager:CheckSystemIsPopup(id)
  local flag = false
  local idStr = self.m_clientData
  if idStr then
    local idList = string.split(idStr, ",")
    for i, v in ipairs(idList) do
      if tostring(v) == tostring(id) then
        flag = true
        return flag
      end
    end
  end
  return flag
end

function UnlockManager:IsSystemOpen(id, showUnlockTip)
  local openFlag, tips_id = UnlockSystemUtil:IsSystemOpen(id)
  if not openFlag and showUnlockTip then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, tips_id)
  end
  return openFlag
end

return UnlockManager
