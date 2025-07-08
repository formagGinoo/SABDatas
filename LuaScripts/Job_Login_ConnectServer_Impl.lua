local Job_Login_ConnectServer_Impl = {}
local CsNet = CS.com.muf.net.client.mfw
local CsNetCore = CS.com.muf.net.core
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

function Job_Login_ConnectServer_Impl.SetupDeviceInfo(msg)
  if nil == msg then
    return
  end
  local bEnterdMaincity = false
  if MTPlatform.isIos then
    msg.mMiscData.idfa = LoginHelper.getUserIdentifier()
    if not bEnterdMaincity then
      msg.mDeviceInfo.gps_adid = ""
      msg.mDeviceInfo.mac_md5 = ""
      msg.mDeviceInfo.android_id = ""
      msg.mDeviceInfo.idfa = LoginHelper.getUserIdentifier()
      msg.mDeviceInfo.idfv = LoginHelper.getVendorID()
      msg.mDeviceInfo.os_name = "ios"
    end
  elseif MTPlatform.isAndroid then
    msg.mMiscData.imei = ""
    msg.mMiscData.firebase_instanceid = LoginHelper.getFirebaseInstanceId()
    if not bEnterdMaincity then
      msg.mDeviceInfo.gps_adid = LoginHelper.getAdvertiseID()
      msg.mDeviceInfo.mac_md5 = LoginHelper.getMacShortMd5()
      msg.mDeviceInfo.android_id = LoginHelper.getAndroidID()
      msg.mDeviceInfo.idfa = ""
      msg.mDeviceInfo.idfv = ""
      msg.mDeviceInfo.os_name = "android"
    end
  elseif MTPlatform.isPCChannel then
    local macID = global:xml_readStringValue("download.bin", "download_guid", "")
    if macID == "" then
      macID = cc.Native:getUniqeID()
    end
    msg.mMiscData.imei = ""
    msg.mDeviceInfo.gps_adid = LoginHelper.getAdvertiseID()
    msg.mDeviceInfo.mac_md5 = macID
    msg.mDeviceInfo.android_id = LoginHelper.getAndroidID()
    msg.mDeviceInfo.idfa = ""
    msg.mDeviceInfo.idfv = ""
    msg.mDeviceInfo.gclid = global:xml_readStringValue("download.bin", "download_gclid", "")
    msg.mDeviceInfo.os_name = "Windows"
  elseif not bEnterdMaincity then
    msg.mDeviceInfo.gps_adid = LoginHelper.getAdvertiseID()
    msg.mDeviceInfo.mac_md5 = LoginHelper.getMacShortMd5()
    msg.mDeviceInfo.android_id = LoginHelper.getAndroidID()
    msg.mDeviceInfo.idfa = ""
    msg.mDeviceInfo.idfv = ""
    msg.mDeviceInfo.os_name = "Windows"
  end
  if not bEnterdMaincity then
    local bLocalWiFiAvailable = NetworkStatusManager:isLocalWiFiAvailable()
    msg.mDeviceInfo.os_build = getOSBuildName()
    msg.mDeviceInfo.os_version = getSystemVersion()
    msg.mDeviceInfo.cpu_type = getCPUType()
    msg.mDeviceInfo.device_manufacturer = getDeviceManufacturer()
    msg.mDeviceInfo.device_name = MTPlatform.sDeviceName
    msg.mDeviceInfo.hardware_name = getHardwareName()
    msg.mDeviceInfo.device_type = getDeviceType()
    msg.mDeviceInfo.screen_density = getScreenDensity()
    msg.mDeviceInfo.screen_format = getScreenFormat()
    msg.mDeviceInfo.screen_size = getScreenSize()
    msg.mDeviceInfo.display_width = getDisplayWidth()
    msg.mDeviceInfo.display_height = getDisplayHeight()
    msg.mDeviceInfo.mcc = getMcc()
    msg.mDeviceInfo.mnc = getMnc()
    msg.mDeviceInfo.network_type = bLocalWiFiAvailable and 0 or 1
    msg.mDeviceInfo.country = cc.Application:getInstance():getCountry()
    msg.mDeviceInfo.language = LanguageService:getCurrentLanguageCode()
  end
end

local function fillDeviceInfo(msg)
  msg.mDeviceInfo.mac_md5 = ""
  if IsIPhonePlatform() then
    msg.mDeviceInfo.idfa = CS.DeviceUtil.GetDeviceUniqueIdentifier()
    msg.mDeviceInfo.idfv = CS.DeviceUtil.GetIDFV()
  else
    msg.mDeviceInfo.idfa = ""
    msg.mDeviceInfo.idfv = ""
  end
  msg.mDeviceInfo.cpu_type = ""
  msg.mDeviceInfo.device_manufacturer = CS.DeviceUtil.GetManufacturer()
  msg.mDeviceInfo.device_name = CS.DeviceUtil.GetTelModel()
  msg.mDeviceInfo.hardware_name = ""
  msg.mDeviceInfo.device_type = ""
  msg.mDeviceInfo.display_width = ""
  msg.mDeviceInfo.display_height = ""
  msg.mDeviceInfo.screen_density = ""
  msg.mDeviceInfo.screen_format = ""
  msg.mDeviceInfo.screen_size = ""
  msg.mDeviceInfo.mcc = ""
  msg.mDeviceInfo.mnc = ""
  msg.mDeviceInfo.network_type = CS.DeviceUtil.IsWIFIConnected() and 0 or 1
  msg.mDeviceInfo.country = CS.LoginContext.GetContext().Country or ""
  msg.mDeviceInfo.language = CS.MultiLanguageManager.Instance:GetLanguageID(CS.MultiLanguageManager.g_iLanguageID) or ""
  msg.mDeviceInfo.os_build = ""
  if IsAndroidPlatform() then
    msg.mDeviceInfo.os_name = "Android"
    msg.mDeviceInfo.os_version = tostring(CS.DeviceUtil.GetAndroidVersionCode())
  elseif IsIPhonePlatform() then
    msg.mDeviceInfo.os_name = "iOS"
    msg.mDeviceInfo.os_version = CS.DeviceUtil.GetIOSVersion()
  else
    msg.mDeviceInfo.os_name = "Windows"
    msg.mDeviceInfo.os_version = ""
  end
end

function Job_Login_ConnectServer_Impl.RequestLoginAuth(fResultCB)
  ReportManager:ReportLoginProcess("InitNetwork_ConnectServer", "LoginAuth_Start")
  local reqMsg = MTTDProto.Cmd_Login_Auth_CS()
  if ChannelManager:IsUsingQSDK() then
    local qsdkAccountInfo = QSDKManager:GetAccountInfo()
    reqMsg.sAccountName = "quicksdk_" .. QSDKManager:GetParentChannelType() .. "_" .. qsdkAccountInfo.uid
    reqMsg.sAuthKey = ""
    reqMsg.sDrmId = CS.DeviceUtil.GetAndroidDrmId()
    reqMsg.sOaId = QSDKManager:GetOaid()
    reqMsg.mMiscData.quick_uid = qsdkAccountInfo.uid
    reqMsg.mMiscData.quick_username = qsdkAccountInfo.userName
    reqMsg.mMiscData.token = qsdkAccountInfo.token
    reqMsg.mMiscData.quick_parent_channel_code = QSDKManager:GetParentChannelType()
    reqMsg.mMiscData.quick_channel_code = QSDKManager:GetChannelType()
    reqMsg.mMiscData.quick_sub_channel_code = QSDKManager:GetSubChannelCode()
  elseif ChannelManager:IsDMMChannel() then
    local dmmAccountInfo = DmmManager:GetAccountInfo()
    reqMsg.sAccountName = "dmm_" .. dmmAccountInfo.viewerId
    reqMsg.sAuthKey = "viewer_id=" .. dmmAccountInfo.viewerId .. "#signature=" .. dmmAccountInfo.signature
    reqMsg.mMiscData.viewer_id = dmmAccountInfo.viewerId
    reqMsg.mMiscData.signature = dmmAccountInfo.signature
    print("dmmAccountInfo.viewerId", dmmAccountInfo.viewerId)
    print("dmmAccountInfo.signature", dmmAccountInfo.signature)
    print("dmmAccountInfo.sAuthKey", reqMsg.sAuthKey)
  else
    reqMsg.sAccountName = "msdk_" .. CS.AccountManager.Instance:GetAccountID()
    reqMsg.sAuthKey = CS.AccountManager.Instance:GetAccountToken()
    reqMsg.mMiscData.did = CS.MSDKManager.Instance:NativeGetDID()
    reqMsg.mMiscData.msdk_callback_info = CS.MSDKManager.Instance:GetCallbackInfo()
    reqMsg.mMiscData.msdk_authkey = CS.AccountManager.Instance:GetAccountToken()
    if CS.ApplicationManager.Instance:IsEnableDebugNova() and UILuaHelper.IsAbleDebugger() then
      local serverId = CS.UnityEngine.PlayerPrefs.GetString("MSDK_PC_MACADDRESS_SERVER_ID")
      if serverId ~= "" then
        reqMsg.iLocalZoneId = tonumber(serverId)
        CS.UnityEngine.PlayerPrefs.SetString("MSDK_PC_MACADDRESS_SERVER_ID", "")
      end
    end
  end
  if IsAndroidPlatform() then
    reqMsg.bSimulator = CS.DeviceUtil.IsEmulatorX86()
    reqMsg.mMiscData.android_id = CS.DeviceUtil.GetAndroidID()
    reqMsg.mMiscData.gps_adid = CS.DeviceUtil.GetAdvertisingID()
  end
  fillDeviceInfo(reqMsg)
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  log.info("sChannel = ", versionContext.Channel)
  reqMsg.sChannel = versionContext.Channel
  reqMsg.sClientVersion = versionContext.ClientLocalVersion
  reqMsg.iRegionId = versionContext.RegionID
  local iLanguage = CS.LuaCallCS.GetSystemLanguageID()
  reqMsg.sOSLanguage = tostring(iLanguage)
  if ChannelManager:IsAndroid() then
    reqMsg.iOSType = MTTDProto.OSType_Android
  elseif ChannelManager:IsIOS() then
    reqMsg.iOSType = MTTDProto.OSType_IOS
  else
    reqMsg.iOSType = MTTDProto.OSType_Win
  end
  NetworkManager:InitCacheShowMessageCfg()
  RPCS():Login_Auth(reqMsg, function(sc, msg)
    ReportManager:ReportLoginProcess("InitNetwork_ConnectServer", "LoginAuth_Success")
    ReportManager:ReportTrackAttributionEvent("register_account", {})
    CS.UserData.Instance.loginAuth = sc
    LuaRepairTable.m_iMaxLuaCodeRepairID = sc.iMaxLuaCodeRepairID
    OnLuaCodeRepair(sc.mLuaCodeRepair)
    log.info("--- login auth success : ", msg.rspcode, " -- -")
    loginContext.AccountID = sc.iAccountId
    if ChannelManager:IsWindows() then
      if not CS.UnityEngine.Application.isEditor then
        CS.BugSplatUtils.Instance:SetUserId(tostring(sc.iAccountId))
      end
    else
      CS.BuglyUtils.Instance:SetUserId(tostring(sc.iAccountId))
    end
    UserDataManager:SetAccountID(sc.iAccountId)
    UserDataManager:SetAccountName(sc.sAccountName)
    loginContext.SessionKey = sc.sSessionKey
    loginContext.CurZoneInfo = sc.stZone
    UserDataManager:SetZoneID(sc.stZone.iZoneId)
    UserDataManager:SetZoneName(sc.stZone.sZoneName)
    EventCenter.Broadcast(EventDefine.eGameEvent_Login_ShowAccountInfo, {
      iAccountID = loginContext.AccountID,
      iZoneID = loginContext.CurZoneInfo.iZoneId
    })
    local sAndroidId = CS.DeviceUtil.GetAndroidID()
    UserDataManager:SetAndroidID(sAndroidId)
    loginContext.AccountList = sc.vAccountInfo
    loginContext.UserIP = sc.sUserIP
    loginContext.Country = sc.sCountry or ""
    loginContext.BNewAccount = sc.bNewAccount
    TimeUtil:SetServerTime(sc.iServerTimeMS)
    TimeUtil:SetServerTimeGmtOff(sc.iTimeGmtOff)
    CS.SDKInit.InitLoginInfo()
    local commonContext = CS.CommonContext.GetContext()
    if IsIPhonePlatform() and sc.stZone.iFlag == MTTDProto.EM_ZoneFlag_Audit then
      commonContext.BIOSReview = true
    end
    if sc.mMiscData and ChannelManager:IsUsingQSDK() then
      QSDKManager:SetMiscData(sc.mMiscData)
    end
    if ChannelManager:IsUsingQSDK() then
      if QSDKManager:CheckAntiAddictionNeedShowTips() then
        utils.CheckAndPushCommonTips({
          tipsID = 1125,
          bLockBack = true,
          func1 = function()
            if fResultCB then
              fResultCB(true)
            end
          end
        })
      elseif fResultCB then
        fResultCB(true)
      end
    elseif fResultCB then
      fResultCB(true)
    end
  end, function(msg)
    ReportManager:ReportLoginProcess("InitNetwork_ConnectServer", "LoginAuth_Failed_" .. msg.rspcode)
    log.error("--- login auth failed : ", msg.rspcode, " ---")
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginConnectServerFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
    if fResultCB then
      fResultCB(false)
    end
  end, function(rec)
    ReportManager:ReportLoginProcess("InitNetwork_ConnectServer", "LoginAuth_Timeout")
    log.error("--- login auth timeout ---")
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginConnectServerFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
    if fResultCB then
      fResultCB(false)
    end
  end, nil, 3, -1)
end

function Job_Login_ConnectServer_Impl.OnConnectServer(jobNode)
  ReportManager:ReportLoginProcess("InitNetwork_ConnectServer", "Connect_Start")
  CS.UserData.Instance:ResetLoginData()
  local client = RPCS().CsSession:GetNetClient(NetClientTypes.Login)
  client:SetAuthRPC(MTTDProto.CmdId_Login_Auth_CS)
  client:SetClientAuthCallback(function(clt, fResultCB)
    ReportManager:ReportLoginProcess("InitNetwork_ConnectServer", "Connect_Success")
    Job_Login_ConnectServer_Impl.RequestLoginAuth(fResultCB)
  end)
  log.info("--- try connect login server ---")
  client:SetClientOpenCallback(function(bSuccess)
    log.info("--- login server connected " .. tostring(bSuccess) .. " ---")
    if bSuccess then
      jobNode.Status = JobStatus.Success
    else
      jobNode.Status = JobStatus.Failed
    end
  end)
  client:Open()
  RPCS().CsSession:GetNetClient(NetClientTypes.Login):Listen(CsNetCore.NetworkEvent.ConnectFailed, function()
    ReportManager:ReportLoginProcess("InitNetwork_ConnectServer", "Connect_Failed")
    log.error("Connect To Login Server Failed")
    utils.CheckAndPushCommonTips({
      title = CS.ConfFact.LangFormat4DataInit("CommonError"),
      content = CS.ConfFact.LangFormat4DataInit("LoginConnectServerFail"),
      funcText1 = CS.ConfFact.LangFormat4DataInit("CommonRetry"),
      btnNum = 1,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
  end)
end

function Job_Login_ConnectServer_Impl.OnConnectServerSuccess(jobNode)
end

function Job_Login_ConnectServer_Impl.OnConnectServerFailed(jobNode)
end

function Job_Login_ConnectServer_Impl.OnConnectServerTimeOut(jobNode)
end

function Job_Login_ConnectServer_Impl.OnConnectServerDispose(jobNode)
end

return Job_Login_ConnectServer_Impl
