local Form_Test = class("Form_Test", require("UI/UIFrames/Form_TestUI"))
require("common/GlobalRequire")

function Form_Test:SetInitParam(param)
end

function Form_Test:AfterInit()
end

function Form_Test:TestUnitSucess()
  log.info("[UI框架] 调用界面里面的方法成功!")
end

function Form_Test:TestLoginAuth()
  local reqMsg = MTTDProto.Cmd_Login_Auth_CS()
  if not IsIPhonePlatform() then
    reqMsg.sAccountName = CS.DeviceUtil.GetDeviceID()
    reqMsg.sAuthKey = "gps_adid=" .. CS.DeviceUtil.GetAdvertisingID() .. "&android_id=" .. CS.DeviceUtil.GetAndroidID()
  else
    reqMsg.sAccountName = CS.DeviceUtil.GetDeviceID()
    reqMsg.sAuthKey = reqMsg.sAccountName
  end
  local sDev_def = ""
  sDev_def = sDev_def .. "country=0&mac_md5=0&hardware_name=0&mnc=0&idfa=0&os_version=0&device_type=0&language=0&gps_adid=0&mcc=0&device_manufacturer=0&display_width=0"
  sDev_def = sDev_def .. "&device_name=0&os_build=0&screen_density=0&cpu_type=0&display_height=0&idfv=0&screen_size=0&screen_format=0&android_id=0&network_type=0&os_name=0"
  reqMsg.sDeviceInfo = sDev_def
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  reqMsg.sChannel = versionContext.Channel
  reqMsg.sClientVersion = versionContext.ClientLocalVersion
  reqMsg.iRegionId = versionContext.RegionID
  local iLanguage = CS.LuaCallCS.GetSystemLanguageID()
  reqMsg.sOSLanguage = tostring(iLanguage)
  if IsAndroidPlatform() then
    reqMsg.iOSType = OSType_Android
    reqMsg.sDeviceInfo = tostring(CS.ComFunc.GetLazyGetAll())
  elseif IsIPhonePlatform() then
    reqMsg.sDeviceInfo = tostring(CS.ComFunc.GetLazyGetAll()) .. "&idfa=" .. CS.DeviceUtil.GetDeviceUniqueIdentifier()
    reqMsg.iOSType = OSType_IOS
  else
    reqMsg.iOSType = OSType_Win
  end
  reqMsg.sUserIP = loginContext.UserIP
  reqMsg.sUnityVersion = CS.ComFunc.GetUnityVersion()
  mtNetworkManager():SendMessageAsync(reqMsg, function(msg, rspcode)
    local loginContext = CS.LoginContext.GetContext()
    loginContext.AccountID = msg.iAccountId
    loginContext.SessionKey = msg.sSessionKey
    loginContext.CurZoneInfo = msg.stZone
    loginContext.AccountList = msg.vAccountInfo
    loginContext.UserIP = msg.sUserIP
    loginContext.Country = msg.sCountry or ""
    loginContext.InternetOperator = msg.sIsp or ""
    loginContext.BNewAccount = msg.bNewAccount
    loginContext.AccountFlag = msg.iAccountFlag
    CS.SDKInit.InitLoginInfo()
    local commonContext = CS.CommonContext.GetContext()
    if IsIPhonePlatform() and msg.stZone.iFlag == EM_ZoneFlag_Audit then
      commonContext.BIOSReview = true
    end
    log.info("Cmd_Login_Auth_CS sucess!!!!")
    if self.TestLoginAuthDone ~= nil then
      self.TestLoginAuthDone(true)
    end
  end, function(msg, rspcode)
    log.info("rspcode : ", rspcode)
    if self.TestLoginAuthDone ~= nil then
      self.TestLoginAuthDone(false)
    end
  end)
end

function Form_Test:TestGetZoneInfo()
  local reqMsg = MTTDProto.Cmd_Login_GetZone_CS()
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  reqMsg.iAccountId = loginContext.AccountID
  reqMsg.sSessionKey = loginContext.SessionKey
  reqMsg.sClientVersion = versionContext.ClientLocalVersion
  reqMsg.sChannel = versionContext.Channel
  mtNetworkManager():SendMessageAsync(reqMsg, function(msg, rspcode)
    local loginContext = CS.LoginContext.GetContext()
    loginContext.ZoneList = loginContext.vZoneList
    loginContext.RoleList = loginContext.vRoleList
    if self.TestGetZoneInfoDone ~= nil then
      self.TestGetZoneInfoDone(true)
    end
  end, function(msg, rspcode)
    if self.TestGetZoneInfoDone ~= nil then
      self.TestGetZoneInfoDone(false)
    end
  end)
end

function Form_Test:TestGetGameServeIP()
  local reqMsg = MTTDProto.Cmd_Login_CheckUpgrade_CS()
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  reqMsg.iAccountId = loginContext.AccountID
  reqMsg.sClientVersion = versionContext.ClientLocalVersion
  reqMsg.sChannel = versionContext.Channel
  reqMsg.sSessionKey = loginContext.SessionKey
  reqMsg.iZoneId = loginContext.CurZoneInfo.iZoneId
  reqMsg.sUserIP = loginContext.UserIP
  mtNetworkManager():SendMessageAsync(reqMsg, function(msg, rescode)
    if #msg.vConnServer > 0 then
      for i, v in ipairs(msg.vConnServer) do
        local ipData = string.split(v, ":")
        if #ipData == 2 then
          loginContext:AddGameServerIp(ipData[1], tonumber(ipData[2]))
        end
      end
      if self.TestGetGameServeIPDone ~= nil then
        self.TestGetGameServeIPDone(true)
      end
    elseif self.TestGetGameServeIPDone ~= nil then
      self.TestGetGameServeIPDone(false)
    end
  end, function(errorMsg, rescode)
    log.info("***** Cmd_Login_CheckUpgrade_CS Failed rescode : ", rescode)
    if self.TestGetGameServeIPDone ~= nil then
      self.TestGetGameServeIPDone(false)
    end
  end)
end

function Form_Test:TestGameNetConnect()
  local loginContext = CS.LoginContext.GetContext()
  local versionContext = CS.VersionContext.GetContext()
  local reqMsg = MTTDProto.Cmd_Net_Connect_CS()
  reqMsg.iAccountId = loginContext.AccountID
  reqMsg.sSessionKey = loginContext.SessionKey
  reqMsg.sClientVersion = versionContext.ClientLocalVersion
  reqMsg.sClientRealVersion = CS.DeviceUtil.GetPackageVersionCode()
  reqMsg.sClientSerial = ""
  reqMsg.sClientLoginVersion = loginContext.ClientLoginVersion
  reqMsg.iZoneId = loginContext.CurZoneInfo.iZoneId
  reqMsg.iReconnectNum = 0
  if IsIPhonePlatform() then
    reqMsg.iOSType = MTTDProto.OSType_IOS
  else
    reqMsg.iOSType = MTTDProto.OSType_Android
  end
  reqMsg.sClientIp = loginContext.UserIP
  reqMsg.sCountry = loginContext.Country
  reqMsg.iClientActivityVersion = 0
  reqMsg.sChannel = versionContext.Channel
  local systemInfo = CS.UnityEngine.SystemInfo
  reqMsg.sDevice = systemInfo.deviceModel .. "-" .. systemInfo.processorType
  reqMsg.sDeviceId = CS.DeviceUtil.GetDeviceID()
  mtNetworkManager():SendMessageAsync(reqMsg, function(msg, rspcode)
    loginContext.SessionKey = msg.sNewSessionKey
    local gameSocket = CS.NetworkManager.Instance:GetSocketByName("Game")
    gameSocket.SendExchangeKeyTime = msg.iExchangeInterval
    if self.TestGameNetConnectDone ~= nil then
      self.TestGameNetConnectDone(true)
    end
  end, function(errorMsg, rspcode)
    if self.TestGameNetConnectDone ~= nil then
      self.TestGameNetConnectDone(false)
    end
  end)
end

local fullscreen = true
ActiveLuaUI("Form_Test", Form_Test)
return Form_Test
