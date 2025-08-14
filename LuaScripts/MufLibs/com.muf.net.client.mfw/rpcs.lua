require("LuaCodeHotfix")
local NetRPCs = class("NetRPCs")

function NetRPCs:ctor()
  self.CsSession = CS.com.muf.net.client.mfw.NetSession.Instance
  self.m_bInited = false
end

function NetRPCs:Init()
  if self.m_bInited then
    return
  end
  self.m_bInited = true
  local loginClient = RPCS().CsSession:AddClient(NetClientTypes.Login, "login")
  local loginIpList = CS.com.muf.net.client.mfw.IpContextUtil.GetLoginIpList()
  loginClient:AddIpList(loginIpList)
  local gameClient = RPCS().CsSession:AddClient(NetClientTypes.Game, "game")
  local netUC = CS.com.muf.net.client.mfw.NetUIController.Instance
  netUC:AddIgnoreRequestId(MTTDProto.CmdId_Net_Idle_CS)
  netUC:AddIgnoreRequestId(MTTDProto.CmdId_Role_ServerTime_CS)
  netUC:Listen()
end

function NetRPCs:RemoveListen(handler)
  if handler == nil then
    log.info("RemoveListen handler == nil")
    return
  end
  self.CsSession:RemoveListen(handler)
end

function NetRPCs:SetRpcCallbackNoneBack(vCmdIds)
  self.CsSession:SetRpcCallbackNoneBack(vCmdIds)
end

function NetRPCs:RegisterRpcCallbackCommonBefore(fRpcCBCommonBefore)
  self.CsSession:RegisterRpcCallbackCommonBefore(fRpcCBCommonBefore)
end

function NetRPCs:RegisterRpcCallbackCommon(fRpcCBCommon)
  self.CsSession:RegisterRpcCallbackCommon(fRpcCBCommon)
end

function NetRPCs:RegisterRpcCallbackFail(fRpcCBFail)
  self.CsSession:RegisterRpcCallbackFail(fRpcCBFail)
end

function NetRPCs:GetRpcCallbackCount()
  return self.CsSession:GetRpcCallbackCount()
end

function RPCS()
  local Managers = require("common/Managers")
  if Managers.rpcs == nil then
    Managers.rpcs = NetRPCs.new()
    Managers.rpcs:Init()
  end
  return Managers.rpcs
end

NetClientTypes = {
  Login = CS.com.muf.net.client.mfw.NetClientType.Login,
  Game = CS.com.muf.net.client.mfw.NetClientType.Game
}
