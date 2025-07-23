local BaseManager = require("Manager/Base/BaseManager")
local NetworkManager = class("NetworkManager", BaseManager)
local CsNetCore = CS.com.muf.net.core
local CsTime = CS.UnityEngine.Time

function NetworkManager:OnCreate()
  self.m_bNetworkInited = false
  self.m_bSessionKeyNeedExchange = false
  self.m_iReconnectNum = 0
  self.m_iHeartBeatTimeout = 30
  self.m_iHeartBeatLastReceiveTime = 0
  self.m_iHeartBeatSendInterval = 6
  self.m_iHeartBeatLastSendTime = 0
  self.m_bForceShowReconnect = true
  self:addEventListener("eGameEvent_PauseGame", handler(self, self.OnPauseGame))
  self:addEventListener("eGameEvent_NetKickOut", handler(self, self.OnKickOut))
end

function NetworkManager:RegisterNetwork()
  self.m_bNetworkInited = true
  self.m_netClientGame = RPCS().CsSession:GetNetClient(NetClientTypes.Game)
  self:InitRpcCallback()
  self.m_netClientGame:SetAuthRPC(MTTDProto.CmdId_Net_Connect_CS)
  self.m_netClientGame:SetClientAuthCallback(function(clt, fResultCB)
    self.m_iHeartBeatLastReceiveTime = CsTime.realtimeSinceStartup
    self.m_iHeartBeatLastSendTime = CsTime.realtimeSinceStartup
    if self.m_netClientGame ~= nil then
      self.m_netClientGame:ResetRpcCostTick()
    end
    
    local function OnNetConnectCB(sc, msg)
      log.info("--- game net connect success : ", msg.rspcode, " ---")
      CS.UserData.Instance.netConnect = sc
      self:ResetSessionKey(sc.sNewSessionKey, sc.iExchangeInterval)
      fResultCB(true)
    end
    
    local function OnNetConnectFail(msg)
      log.error("--- game net connect failed : ", msg.rspcode, " ---")
      if msg.rspcode == MTTD.Error_SessionExpired or msg.rspcode == MTTD.Error_NoAuth then
        self.m_bSessionExpired = true
      end
      fResultCB(false)
    end
    
    local function OnNetConnectTimeout(rec)
      log.error("--- game net connect timeout ---")
      fResultCB(false)
    end
    
    self:RequestGameNetConnect(OnNetConnectCB, OnNetConnectFail, OnNetConnectTimeout)
  end)
  self.m_netClientGame:SetClientOpenCallback(function(bSuccess)
    log.info("--- game server reconnected " .. tostring(bSuccess) .. " ---")
    if bSuccess then
      self.m_bNetworkInited = true
      self:broadcastEvent("eGameEvent_NetworkGame_Reconnect")
    end
  end)
  self.m_netClientGame:RemoveListenByEventId(CsNetCore.NetworkEvent.ConnectFailed)
  self.m_netClientGame:Listen(CsNetCore.NetworkEvent.ConnectFailed, function()
    local netUC = CS.com.muf.net.client.mfw.NetUIController.Instance
    local iRequestLockerCount = 0
    local sRequestLockerDetail = ""
    if netUC ~= nil then
      local dictRequestLockers = netUC:GetRequestLockers()
      iRequestLockerCount = dictRequestLockers.Count
      local mRequestLockersInfo = {}
      for k, v in pairs(dictRequestLockers) do
        mRequestLockersInfo[tostring(k)] = v.messageId
      end
      sRequestLockerDetail = json.encode(mRequestLockersInfo)
    end
    log.error("Connect To Game Server Failed, RequestLockerCount " .. tostring(iRequestLockerCount) .. "\n" .. sRequestLockerDetail)
    if self.m_bForceShowReconnect or not self.m_bSessionExpired and 0 < iRequestLockerCount then
      ReportManager:ReportClientNetShowReconnect(0, sRequestLockerDetail)
      if ChannelManager:IsWindows() or ChannelManager:IsIOS() then
        utils.CheckAndPushCommonTips({
          title = CS.ConfFact.LangFormat4DataInit("CommonError"),
          content = CS.ConfFact.LangFormat4DataInit("LoginConnectGameServerFail"),
          funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
          btnNum = 1,
          bLockBack = true,
          func1 = function()
            self.m_iHeartBeatLastReceiveTime = CsTime.realtimeSinceStartup
            self.m_netClientGame:SetLockReconnect(false)
            self.m_netClientGame:ReconnectExhausted()
          end
        })
      else
        utils.CheckAndPushCommonTips({
          title = CS.ConfFact.LangFormat4DataInit("CommonError"),
          content = CS.ConfFact.LangFormat4DataInit("LoginConnectGameServerFail"),
          funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
          funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
          btnNum = 2,
          bLockBack = true,
          func1 = function()
            self.m_iHeartBeatLastReceiveTime = CsTime.realtimeSinceStartup
            self.m_netClientGame:SetLockReconnect(false)
            self.m_netClientGame:ReconnectExhausted()
          end,
          func2 = function()
            CS.ApplicationManager.Instance:RestartGame()
          end
        })
      end
      self.m_bNetworkInited = false
      self.m_netClientGame:SetLockReconnect(true)
    end
  end)
end

function NetworkManager:OnInitNetwork()
  self.m_bForceShowReconnect = false
end

function NetworkManager:OnPauseGame(bPaused)
  if RPCS == nil then
    return
  end
  if not self.m_bNetworkInited then
    return
  end
  if not bPaused then
    self:TryRequestHeartBeat(true)
  end
end

function NetworkManager:OnKickOut()
  self.m_bNetworkInited = false
  if self.m_netClientGame ~= nil then
    self.m_netClientGame:SetLockReconnect(true)
    self.m_netClientGame:Close()
  end
  self.m_netClientGame = nil
end

function NetworkManager:OnSessionExpired()
  local function OnClientClose()
    log.error("Session Key Expired")
    
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("ConfirmCommonTipsContent9988"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
    self.m_netClientGame:SetLockReconnect(true)
  end
  
  self.m_bNetworkInited = false
  if self.m_netClientGame ~= nil then
    if self.m_iHandlerNetClientGameClose == nil then
      self.m_iHandlerNetClientGameClose = self.m_netClientGame:Listen(CS.com.muf.net.core.NetworkEvent.Close, OnClientClose)
    end
    self.m_netClientGame:Close()
  end
end

function NetworkManager:OnUpdate(dt)
  if ChannelManager:IsChinaChannel() then
    local reportService = CS.ReportService.Instance
    if reportService ~= nil then
      reportService:Update()
    end
  end
  if self.m_netClientGame == nil then
    return
  end
  local netUC = CS.com.muf.net.client.mfw.NetUIController.Instance
  if netUC ~= nil then
    netUC:OnUpdate()
  end
  if self.m_netClientGame ~= nil and self.m_netClientGame:IsOpened() and self:CheckHeartBeatTimeout() then
    self.m_bNetworkInited = false
    self.m_iHeartBeatLastReceiveTime = CsTime.realtimeSinceStartup
    self.m_netClientGame:Reconnect()
    return
  end
  if not self.m_bNetworkInited then
    return
  end
  if not self.m_bSessionExpired then
    if self.m_iSessionKeyExchangeInterval ~= nil and self.m_iSessionKeyStartTime ~= nil and CsTime.realtimeSinceStartup - self.m_iSessionKeyStartTime >= self.m_iSessionKeyExchangeInterval then
      self.m_bSessionKeyNeedExchange = true
    end
    if self.m_bSessionKeyNeedExchange then
      self:ExchangeSessionKey()
    end
  end
  self:TryRequestHeartBeat()
end

function NetworkManager:InitCacheShowMessageCfg()
  self.m_stShowMessageConfig = ConfigManager:GetConfigInsByName("ShowMessage")
end

function NetworkManager:InitRpcCallback()
  self.m_iHeartBeatLastReceiveTime = CsTime.realtimeSinceStartup
  self.m_iHeartBeatLastSendTime = CsTime.realtimeSinceStartup
  RPCS():SetRpcCallbackNoneBack({
    MTTDProto.CmdId_Net_NotifyPush_CS
  })
  RPCS():RegisterRpcCallbackCommonBefore(handler(self, self.OnRpcCallbackCommonBefore))
  RPCS():RegisterRpcCallbackCommon(handler(self, self.OnRpcCallbackCommon))
  RPCS():RegisterRpcCallbackFail(handler(self, self.OnRpcCallbackFail))
end

function NetworkManager:ResetSessionKey(sSessionKey, iSessionKeyExchangeInterval)
  log.info("ResetSessionKey: " .. sSessionKey .. ", ExchangeInterval: " .. iSessionKeyExchangeInterval)
  self.m_bSessionKeyNeedExchange = false
  CS.LoginContext.GetContext().SessionKey = sSessionKey
  self.m_iSessionKeyExchangeInterval = iSessionKeyExchangeInterval
  self.m_iSessionKeyStartTime = CsTime.realtimeSinceStartup
end

function NetworkManager:ExchangeSessionKey()
  if not self.m_bNetworkInited then
    return
  end
  if not self.m_bSessionKeyNeedExchange then
    return
  end
  self.m_bSessionKeyNeedExchange = false
  self.m_iSessionKeyStartTime = CsTime.realtimeSinceStartup
  local reqMsg = MTTDProto.Cmd_Net_Exchange_SessionKey_CS()
  
  local function OnExchangeSessionKey(sc, msg)
    self:ResetSessionKey(sc.sNewSessionKey, self.m_iSessionKeyExchangeInterval)
  end
  
  log.info("Request ExchangeSessionKey")
  RPCS():Net_Exchange_SessionKey(reqMsg, OnExchangeSessionKey, nil, nil, nil, nil, -1)
end

function NetworkManager:OnRpcCallbackCommonBefore(rec, msg, bt)
  if not msg:IsResponse() then
    self:RequestNotifyPush(msg.rspseq)
  end
end

function NetworkManager:OnRpcCallbackCommon(rec, msg, bt)
  self.m_iHeartBeatLastReceiveTime = CsTime.realtimeSinceStartup
  if rec ~= nil then
    self.m_iHeartBeatLastSendTime = CsTime.realtimeSinceStartup
  end
  if msg.rspcode == MTTD.Error_SessionExpired or msg.rspcode == MTTD.Error_NoAuth then
    self.m_bSessionExpired = true
    self:OnSessionExpired()
  end
  if msg.rspcode == MTTD.Error_Client_TooOld then
    PushMessageManager:OnPushMessage({
      iReason = MTTDProto.KickReason_ClientNewVersion
    })
  end
end

function NetworkManager:RequestNotifyPush(iPushSeqId)
  log.info("NotifyPush: " .. iPushSeqId)
  local reqMsg = MTTDProto.Cmd_Net_NotifyPush_CS()
  reqMsg.iPushSeqId = iPushSeqId
  RPCS():Net_NotifyPush(reqMsg, nil, nil, nil, nil, nil, -1)
end

function NetworkManager:OnRpcCallbackFail(msg, fConfirmCB)
  if msg == nil or msg.rspcode == 0 then
    return
  end
  local iErrorCode = msg.rspcode
  log.error("Message Error Code: ", iErrorCode)
  local sContent = ConfigManager:GetCommonTextById(20005) .. iErrorCode
  if iErrorCode == 1017 then
    utils.CheckAndPushCommonTips({
      tipsID = 1222,
      func1 = function()
        QuickOpenFuncUtil:OpenFunc(GlobalConfig.RECHARGE_JUMP)
      end
    })
    return
  end
  if self.m_stShowMessageConfig then
    local element = self.m_stShowMessageConfig:GetValue_ByID(iErrorCode)
    if element.m_IsShow == 1 then
      if element and element.m_mMessage then
        sContent = element.m_mMessage
      end
      if UILuaHelper.IsAbleDebugger() then
        sContent = sContent .. "(" .. tostring(iErrorCode) .. ")"
      end
      self:ShowErrorCodePop(element.m_ShowType, sContent, fConfirmCB)
    else
      log.info("OnRpcCallbackFail is not show ")
    end
  else
    log.error("OnRpcCallbackFail ShowMessageConfig is null！！！ " .. tostring(sContent))
  end
end

function NetworkManager:ShowErrorCodePop(showType, sContent, fConfirmCB)
  if showType == 1 then
    local tParam = {}
    tParam.content = sContent
    tParam.title = ConfigManager:GetCommonTextById(20004)
    tParam.funcText1 = ConfigManager:GetCommonTextById(20006)
    tParam.btnNum = 1
    tParam.func1 = fConfirmCB
    tParam.bLockBack = true
    utils.CheckAndPushCommonTips(tParam)
  elseif showType == 2 then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, sContent)
  end
end

function NetworkManager:RequestGameNetConnect(OnNetConnectCB, OnNetConnectFail, OnNetConnectTimeout)
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  local reqMsg = MTTDProto.Cmd_Net_Connect_CS()
  reqMsg.iAccountId = loginContext.AccountID
  reqMsg.sSessionKey = loginContext.SessionKey
  reqMsg.sClientVersion = versionContext.ClientLocalVersion
  reqMsg.iZoneId = loginContext.CurZoneInfo.iZoneId
  log.info("GameNetConnect: AccountID: " .. reqMsg.iAccountId .. ", ZoneID: " .. reqMsg.iZoneId)
  reqMsg.iReconnectNum = self.m_iReconnectNum
  self.m_iReconnectNum = self.m_iReconnectNum + 1
  if ChannelManager:IsAndroid() then
    reqMsg.iOSType = MTTDProto.OSType_Android
  elseif ChannelManager:IsIOS() then
    reqMsg.iOSType = MTTDProto.OSType_IOS
  else
    reqMsg.iOSType = MTTDProto.OSType_Win
  end
  reqMsg.sClientIp = loginContext.UserIP
  reqMsg.sChannel = versionContext.Channel
  reqMsg.sDeviceId = CS.DeviceUtil.GetDeviceID()
  RPCS():Net_Connect(reqMsg, OnNetConnectCB, OnNetConnectFail, OnNetConnectTimeout, nil, nil, -1)
end

function NetworkManager:TryRequestHeartBeat(bForce)
  if RPCS ~= nil and RPCS().CsSession:GetRpcMsgCountByClientType(NetClientTypes.Game) > 0 then
    return
  end
  local iLastSendTime = self.m_iHeartBeatLastSendTime
  local iCurTime = CsTime.realtimeSinceStartup
  if bForce or iCurTime - iLastSendTime > self.m_iHeartBeatSendInterval then
    log.info("Request HeartBeat(Net_Idle)")
    local reqMsg = MTTDProto.Cmd_Net_Idle_CS()
    RPCS():Net_Idle(reqMsg)
    self.m_iHeartBeatLastSendTime = iCurTime
  end
end

function NetworkManager:CheckHeartBeatTimeout()
  local iLastReceiveTime = self.m_iHeartBeatLastReceiveTime
  local iCurTime = CsTime.realtimeSinceStartup
  return iCurTime - iLastReceiveTime > self.m_iHeartBeatTimeout
end

return NetworkManager
