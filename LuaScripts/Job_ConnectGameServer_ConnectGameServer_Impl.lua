local Job_ConnectGameServer_ConnectGameServer_Impl = {}
local CsNet = CS.com.muf.net.client.mfw
local CsNetCore = CS.com.muf.net.core

function Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServer(jobNode)
  ReportManager:ReportLoginProcess("InitNetworkGame_ConnectGameServer", "Connect_Start")
  require("hotfix/hotfix_entry")
  log.info("--- close connect of login server ---")
  RPCS().CsSession:RemoveClient(NetClientTypes.Login)
  local gameClient = RPCS().CsSession:GetNetClient(NetClientTypes.Game)
  local loginContext = CS.LoginContext.GetContext()
  local proxys = loginContext.GameServerIPList
  gameClient:AddIpList(proxys)
  gameClient:SetAuthRPC(MTTDProto.CmdId_Net_Connect_CS)
  gameClient:SetClientAuthCallback(function(clt, fResultCB)
    ReportManager:ReportLoginProcess("InitNetworkGame_ConnectGameServer", "Connect_Success")
    gameClient:ResetRpcCostTick()
    
    local function OnNetConnectCB(sc, msg)
      ReportManager:ReportLoginProcess("InitNetworkGame_ConnectGameServer", "NetConnect_Success")
      log.info("--- game net connect success : ", msg.rspcode, " ---")
      CS.UserData.Instance.netConnect = sc
      NetworkManager:ResetSessionKey(sc.sNewSessionKey, sc.iExchangeInterval)
      fResultCB(true)
    end
    
    local function OnNetConnectFail(msg)
      ReportManager:ReportLoginProcess("InitNetworkGame_ConnectGameServer", "NetConnect_Failed_" .. msg.rspcode)
      log.error("--- game net connect failed : ", msg.rspcode, " ---")
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = CS.ConfFact.LangFormat4DataInit("LoginConnectGameServerFail"),
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
        funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
        btnNum = 2,
        bLockBack = true,
        func1 = function()
          gameClient:ReconnectExhausted()
        end,
        func2 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
      fResultCB(false)
    end
    
    local function OnNetConnectTimeout(rec)
      ReportManager:ReportLoginProcess("InitNetworkGame_ConnectGameServer", "NetConnect_Timeout")
      log.error("--- game net connect timeout ---")
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = CS.ConfFact.LangFormat4DataInit("LoginConnectGameServerFail"),
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
        funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
        btnNum = 2,
        bLockBack = true,
        func1 = function()
          gameClient:ReconnectExhausted()
        end,
        func2 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
      fResultCB(false)
    end
    
    ReportManager:ReportLoginProcess("InitNetworkGame_ConnectGameServer", "NetConnect_Start")
    NetworkManager:RequestGameNetConnect(OnNetConnectCB, OnNetConnectFail, OnNetConnectTimeout)
  end)
  gameClient:RemoveListenByEventId(CsNetCore.NetworkEvent.ConnectFailed)
  gameClient:Listen(CsNetCore.NetworkEvent.ConnectFailed, function()
    ReportManager:ReportLoginProcess("InitNetworkGame_ConnectGameServer", "Connect_Failed")
    log.error("Connect To Game Server Failed")
  end)
  log.info("--- try connect game server " .. proxys[0].ip .. ":" .. proxys[0].port .. " ---")
  gameClient:SetClientOpenCallback(function(bSuccess)
    log.info("--- game server connected " .. tostring(bSuccess) .. " ---")
    if bSuccess then
      NetworkManager:RegisterNetwork()
      jobNode.Status = JobStatus.Success
    else
    end
  end)
  gameClient:Open()
end

function Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServerSuccess(jobNode)
end

function Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServerFailed(jobNode)
end

function Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServerTimeOut(jobNode)
end

function Job_ConnectGameServer_ConnectGameServer_Impl.OnConnectGameServerDispose(jobNode)
end

return Job_ConnectGameServer_ConnectGameServer_Impl
