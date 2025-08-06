local Job_ConnectGameServer_Game_Role_Init_Impl = {}

function Job_ConnectGameServer_Game_Role_Init_Impl.RequestRoleInit(jobNode)
  ReportManager:ReportLoginProcess("InitNetworkGame_RoleInit", "RoleInit_Start")
  GameManager:initLoginPush()
  local loginContext = CS.LoginContext:GetContext()
  local systemInfo = CS.UnityEngine.SystemInfo
  local reqMsg = MTTDProto.Cmd_Role_Init_CS()
  reqMsg.sChannel = ChannelManager:GetContext().Channel
  reqMsg.sDevice = systemInfo.deviceModel .. "-" .. systemInfo.processorType
  if ChannelManager:IsAndroid() then
    reqMsg.iOSType = MTTDProto.OSType_Android
  elseif ChannelManager:IsIOS() then
    reqMsg.iOSType = MTTDProto.OSType_IOS
  else
    reqMsg.iOSType = MTTDProto.OSType_Win
  end
  reqMsg.sClientVersion = ChannelManager:GetContext().ClientRealVersion
  local languageInfo = CData_MultiLanguage:GetValue_ByID(CS.MultiLanguageManager.g_iLanguageID)
  reqMsg.iLanguageId = languageInfo and languageInfo.m_LanID or 101
  reqMsg.sUserIp = loginContext.UserIP
  if IsAndroidPlatform() then
    reqMsg.sIDFA = ""
    reqMsg.sGAID = CS.DeviceUtil.GetAdvertisingID()
    reqMsg.sAndroidId = CS.DeviceUtil.GetAndroidID()
    reqMsg.iAccType = MTTDProto.AccountType_MSdkAnd
    reqMsg.bSimulator = CS.DeviceUtil.IsEmulatorX86()
  else
    reqMsg.sIDFA = CS.DeviceUtil.GetDeviceUniqueIdentifier()
    reqMsg.sIDFV = CS.DeviceUtil.GetIDFV()
    reqMsg.sGAID = CS.DeviceUtil.GetAdvertisingID()
    reqMsg.iAccType = MTTDProto.AccountType_MSdkIos
  end
  reqMsg.sDeviceId = CS.DeviceUtil.GetDeviceID()
  if ChannelManager:IsUsingQSDK() then
    reqMsg.sOaId = QSDKManager:GetOaid()
    reqMsg.sDrmId = CS.DeviceUtil.GetAndroidDrmId()
    local qsdkAccountInfo = QSDKManager:GetAccountInfo()
    reqMsg.sAccount = "quicksdk_" .. QSDKManager:GetParentChannelType() .. "_" .. qsdkAccountInfo.uid
    reqMsg.iAccType = MTTDProto.AccountType_QuickSDK
    reqMsg.sParentQuickChannelCode = QSDKManager:GetParentChannelType()
    reqMsg.sQuickChannelCode = QSDKManager:GetChannelType()
    reqMsg.sQuickSubChannelCode = QSDKManager:GetSubChannelCode()
  elseif ChannelManager:IsDMMChannel() then
    local dmmAccountInfo = DmmManager:GetAccountInfo()
    reqMsg.sAccount = "dmm_" .. dmmAccountInfo.viewerId
  elseif ChannelManager:IsWegameChannel() then
    local wegameAccountInfo = WegameManager:GetAccountInfo()
    reqMsg.sAccount = "wegame_" .. wegameAccountInfo.railId
  else
    reqMsg.sAccount = "msdk_" .. CS.AccountManager.Instance:GetAccountID()
  end
  reqMsg.sOSCountry = CS.DeviceUtil.GetCountry()
  reqMsg.bInWhiteList = CS.UserData.Instance.loginAuth.bInWhiteList
  reqMsg.sAreaId = CS.VersionContext.GetContext().AreaId
  reqMsg.sTagId = CS.VersionContext.GetContext().Tag
  local iFirstPackPAD = LocalDataManager:GetIntSimple("FirstPack_PAD", -1)
  if iFirstPackPAD == -1 then
    if DownloadManager:ShouldDownloadResource("MainLevel_01_01_EP01.mp4", DownloadManager.ResourceType.Video) then
      iFirstPackPAD = 0
    else
      iFirstPackPAD = 1
    end
    LocalDataManager:SetIntSimple("FirstPack_PAD", iFirstPackPAD)
  end
  reqMsg.bWholePackage = iFirstPackPAD == 1
  RPCS():Role_Init(reqMsg, function(sc, msg)
    ReportManager:ReportLoginProcess("InitNetworkGame_RoleInit", "RoleInit_Success")
    CS.UserData.Instance.roleInit = sc
    CS.UserData.Instance.sLoginRoleCountry = sc.sLoginRoleCountry
    log.info("--- game role init success : ", msg.rspcode, " ---")
    log.info("RoleID: " .. sc.iUid .. ", Name: " .. sc.sName)
    RoleManager:InitRole(sc)
    if sc and sc.bNewRole then
      ReportManager:ReportTrackAttributionEvent("create_role", {})
      if ChannelManager:IsUsingQSDK() then
        QSDKManager:CreateRole()
      end
    end
    if ChannelManager:IsUsingQSDK() then
      QSDKManager:EnterGame()
      local qsdkAccountInfo = QSDKManager:GetAccountInfo()
      CS.GameProtectBridge.Instance:SetUserInfo(0, qsdkAccountInfo.uid, UserDataManager:GetZoneID(), RoleManager:GetUID())
    elseif ChannelManager:IsWegameChannel() then
      local wegameAccountInfo = WegameManager:GetAccountInfo()
      CS.GameProtectBridge.Instance:SetUserInfo(0, wegameAccountInfo.railId, UserDataManager:GetZoneID(), RoleManager:GetUID())
    else
      CS.GameProtectBridge.Instance:SetUserInfo(0, CS.AccountManager.Instance:GetAccountID(), UserDataManager:GetZoneID(), RoleManager:GetUID())
    end
    CS.ReportService.Instance:SetUserInfoVerbose(UserDataManager:GetAccountID(), UserDataManager:GetZoneID(), sc.iLevel, sc.iRoleRegTime, TimeUtil:TimerToString2(sc.iRoleRegTime), sc.iTotalRechargeDiamond)
    LuaRepairTable.m_iMaxLuaCodeRepairID = sc.iMaxLuaCodeRepairID
    OnLuaCodeRepair(sc.mLuaCodeRepair)
    if sc.vRepairStr ~= nil and 0 < #sc.vRepairStr then
      for _, v in pairs(sc.vRepairStr) do
        if v.sItemValue and v.sItemValue ~= "" then
          CS.DataModifier.PushDataModifier(v.sTableName, v.sKey1, v.sValue1, v.sKey2, v.sValue2, v.sItemKey, v.sItemValue)
        end
      end
    end
    TimeUtil:SetServerTime(sc.stServerConfigData.iServerTimeMS)
    TimeUtil:SetServerTimeGmtOff(sc.stServerConfigData.iTimeGmtOff)
    TimeUtil:InitTimer()
    ItemManager:SetSpecialItem(sc.mSpecialItem)
    PushNotificationManager:SetPushOptionFromServer(sc.mPushOption)
    jobNode.Status = JobStatus.Success
  end, function(msg)
    ReportManager:ReportLoginProcess("InitNetworkGame_RoleInit", "RoleInit_Failed")
    log.info("--- game role init failed : ", msg.rspcode, " ---")
    if msg.rspcode == MTTD.Error_Role_BanLogin then
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("LoginRoleBanTitle"),
        content = CS.ConfFact.LangFormat4DataInit("LoginRoleBanDesc"),
        fContentCB = function(content)
          local info = sdp.unpack(msg.bt:ToBytes(), MTTDProto.Cmd_Push_Error)
          local timestamp = info.mParam.ban_remain + TimeUtil:GetServerTimeS()
          return string.gsubnumberreplace(content, os.date("%Y-%m-%d %H:%M:%S", timestamp))
        end,
        funcText1 = CS.ConfFact.LangFormat4DataInit("LoginRoleBanChangeAccount"),
        funcText2 = CS.ConfFact.LangFormat4DataInit("LoginRoleBanCustomer"),
        btnNum = 2,
        bLockBack = true,
        func1 = function()
          SDKUtil.SwitchAccount()
        end,
        func2 = function()
          SettingManager:PullAiHelpMessage("E002")
        end
      })
    else
      utils.CheckAndPushCommonTips({
        title = CS.ConfFact.LangFormat4DataInit("CommonError"),
        content = CS.ConfFact.LangFormat4DataInit("LoginRoleInitFail"),
        funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
        funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
        btnNum = 2,
        bLockBack = true,
        func1 = function()
          Job_ConnectGameServer_Game_Role_Init_Impl.RequestRoleInit(jobNode)
        end,
        func2 = function()
          CS.ApplicationManager.Instance:RestartGame()
        end
      })
    end
  end, function(rec)
    ReportManager:ReportLoginProcess("InitNetworkGame_RoleInit", "RoleInit_TimeOut")
    log.info("--- game role init timeout ---")
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginRoleInitFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      funcText2 = CS.ConfFact.LangFormat4DataInit("CommonReLogin"),
      btnNum = 2,
      bLockBack = true,
      func1 = function()
        Job_ConnectGameServer_Game_Role_Init_Impl.RequestRoleInit(jobNode)
      end,
      func2 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  end, nil, nil, -1)
end

function Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_Init(jobNode)
  Job_ConnectGameServer_Game_Role_Init_Impl.RequestRoleInit(jobNode)
end

function Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_InitSuccess(jobNode)
end

function Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_InitFailed(jobNode)
end

function Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_InitTimeOut(jobNode)
end

function Job_ConnectGameServer_Game_Role_Init_Impl.OnGame_Role_InitDispose(jobNode)
end

return Job_ConnectGameServer_Game_Role_Init_Impl
