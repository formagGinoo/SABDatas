local BaseManager = require("Manager/Base/BaseManager")
local ClientDataManager = class("ClientDataManager", BaseManager)

function ClientDataManager:OnCreate()
  self.m_clientData = {}
end

function ClientDataManager:OnInitNetwork()
end

function ClientDataManager:OnUpdate(dt)
end

function ClientDataManager:OnAfterInitConfig()
  ClientDataManager.ClientKeyType = {
    Unlock = MTTDProto.CmdClientDataType_Unlock,
    Guide = MTTDProto.CmdClientDataType_Guide,
    Level_MainEnter = MTTDProto.CmdClientDataType_MainEnter,
    Level_TowerEnter = MTTDProto.CmdClientDataType_Tower,
    Level_ArenaEnter = MTTDProto.CmdClientDataType_Arena,
    Gacha = MTTDProto.CmdClientDataType_Gacha,
    Statue = MTTDProto.CmdClientDataType_Statue,
    Level_Lamia_Enter = MTTDProto.CmdClientDataType_LamiaEnter,
    Explore = MTTDProto.CmdClientDataType_Explore,
    LegacyLevel = MTTDProto.CmdClientDataType_LegacyLevel,
    LegacyGuide = MTTDProto.CmdClientDataType_LegacyGuide,
    HallDecorate = MTTDProto.CmdClientDataType_HallDecoration
  }
end

function ClientDataManager:OnAfterFreshData()
end

function ClientDataManager:OnClientDataGetDataSC(stClientDataSC, msg)
  if not stClientDataSC then
    return
  end
  self.m_clientData = stClientDataSC.mData or {}
end

function ClientDataManager:ReqClientDataSetData(clientDataKey, cmdClientData)
  if not clientDataKey then
    return
  end
  local msg = MTTDProto.Cmd_ClientData_SetData_CS()
  msg.mData = {
    [clientDataKey] = cmdClientData
  }
  RPCS():ClientData_SetData(msg, handler(self, self.OnClientDataSetDataSC))
end

function ClientDataManager:OnClientDataSetDataSC(stClientDataSC, msg)
  if not stClientDataSC then
    return
  end
end

function ClientDataManager:GetClientValueStringByKey(clientDataKey)
  if not clientDataKey then
    return
  end
  local cmdClientData = self.m_clientData[clientDataKey]
  if not cmdClientData then
    return
  end
  return cmdClientData.sClientData
end

function ClientDataManager:SetClientValue(clientDataKey, valueStr, expireTime, actId)
  if not clientDataKey then
    return
  end
  valueStr = valueStr or ""
  actId = actId or 0
  expireTime = expireTime or 0
  if not self.m_clientData[clientDataKey] then
    self.m_clientData[clientDataKey] = {
      iExpireTime = expireTime,
      iActId = actId,
      sClientData = valueStr
    }
  else
    self.m_clientData[clientDataKey].iExpireTime = expireTime
    self.m_clientData[clientDataKey].iActId = actId
    self.m_clientData[clientDataKey].sClientData = valueStr
  end
  local cmdClientData = self.m_clientData[clientDataKey]
  self:ReqClientDataSetData(clientDataKey, cmdClientData)
end

return ClientDataManager
