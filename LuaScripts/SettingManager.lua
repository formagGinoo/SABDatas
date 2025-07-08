local BaseManager = require("Manager/Base/BaseManager")
local SettingManager = class("SettingManager", BaseManager)

function SettingManager:OnCreate()
  self.isEnterHallInLogin = true
  self.isEnterCastleInHall = true
end

function SettingManager:OnInitNetwork()
  RPCS():Listen_Push_Elva_Message(handler(self, self.OnPushAiHelpMessage), "SettingManager")
end

function SettingManager:OnPushAiHelpMessage()
  self:OnCheckAiHelpMessageRedDot(1)
end

function SettingManager:OnCheckAiHelpMessageRedDot(curUnReadMessage)
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.SettingCustomerService,
    count = curUnReadMessage
  })
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.LoginCustomerService,
    count = curUnReadMessage
  })
  self:broadcastEvent("eGameEvent_RedDot_ChangeCount", {
    redDotKey = RedDotDefine.ModuleType.PayShopCustomerService,
    count = curUnReadMessage
  })
end

function SettingManager:OnReadElvaMessage_CS()
  local reqMsg = MTTDProto.Cmd_Role_ReadElvaMessage_CS()
  RPCS():Role_ReadElvaMessage(reqMsg, handler(self, self.OnReadElvaMessage_SC))
end

function SettingManager:OnReadElvaMessage_SC()
  if self.sEntryID == nil then
    self.sEntryID = "E001"
  end
  self:OnCheckAiHelpMessageRedDot(0)
  local userId = RoleManager:GetUID() or ""
  local userName = RoleManager:GetName() or ""
  local userLv = RoleManager:GetLevel() or 1
  local versionContext = CS.VersionContext.GetContext().ClientLocalVersionFull or ""
  local serverId = tostring(UserDataManager:GetZoneID()) or ""
  local serverIds = "s" .. serverId
  local totalLv = userLv + (5 - userLv % 5)
  local lvTag = "lv" .. userLv .. "-" .. totalLv
  local tag = string.format("[%s, %s, %s]", versionContext, serverIds, lvTag) or ""
  local sDeviceId = CS.DeviceUtil.GetDeviceID() or ""
  local sDeviceCpu = CS.DeviceUtil.GetCPU() or ""
  local freeSpacePhone = tostring(CS.DeviceUtil.GetPersistentDataPathAvailableSize() * 1024 * 1024) or ""
  local totalSpacePhone = tostring(CS.DeviceUtil.GetPersistentDataPathTotalSize() * 1024 * 1024) or ""
  local deviceModel = CS.DeviceUtil.GetTelModel() or ""
  local applicationIdentifier = CS.DeviceUtil.GetPackageName() or ""
  local s_iTotalRecharge = RoleManager:GetTotalRecharge() or ""
  local sCreateRoleCountry = RoleManager:GetCreateRoleCountry() or ""
  local sLoginRoleCountry = RoleManager:GetLoginRoleCountry() or ""
  local sChannel = ChannelManager:GetContext().Channel or ""
  local language = self:GetAiHelpCanIdentifyLanguage(CS.MultiLanguageManager.g_iLanguageID) or ""
  local userInfo = {
    client_ver = versionContext,
    device_id = sDeviceId,
    device_cpu = sDeviceCpu,
    total_recharge = s_iTotalRecharge,
    create_role_region = sCreateRoleCountry,
    login_region = sLoginRoleCountry,
    language = language,
    channel = sChannel
  }
  local userInfoJson = json.encode(userInfo)
  local signedParams = {
    userId = userId,
    userName = userName,
    serverId = serverId,
    userTags = tag,
    freeSpacePhone = freeSpacePhone,
    totalSpacePhone = totalSpacePhone,
    applicationIdentifier = applicationIdentifier,
    applicationVersion = versionContext,
    entranceId = self.sEntryID,
    deviceModel = deviceModel
  }
  local signedParamsJson = json.encode(signedParams)
  if ChannelManager:IsChinaChannel() then
    local stLoginConfigBuilder = CS.AIHelp.LoginConfig.Builder()
    stLoginConfigBuilder:SetUserId(userId)
    local stUserConfigBuilder = CS.AIHelp.UserConfig.Builder()
    stUserConfigBuilder:SetUserName(userName)
    stUserConfigBuilder:SetServerId(serverId)
    stUserConfigBuilder:SetUserTags(tag)
    stUserConfigBuilder:SetCustomData(userInfoJson)
    local stUserConfig = stUserConfigBuilder:Build()
    stLoginConfigBuilder:SetUserConfig(stUserConfig)
    local stLoginConfig = stLoginConfigBuilder:Build()
    CS.AIHelp.AIHelpSupport.Login(stLoginConfig)
  else
    CS.AiHelpManager.Instance:AiHelpUpdateUserInfo(userId, userName, serverId, tag, userInfoJson)
  end
  if ChannelManager:IsWindows() then
    local domain = "ml.aihelp.net"
    local appId = "ml_platform_28952163347e9d6759af141d2bfb1d6e"
    if ChannelManager:IsUSChannel() then
      appId = "nova_platform_c6c4e6bd86747f6b8d699ed6689128db"
    end
    if ChannelManager:IsChinaChannel() then
      domain = "ml.aihelpcn.net"
      appId = "ml_platform_3e3dce2a3a234508d772a7576ca69520"
    end
    local signedParamsEncrypts = UILuaHelper.AiHelpParamEncrypt(signedParamsJson, appId)
    local customData = UILuaHelper.AiHelpParamEncrypt(userInfoJson, appId)
    local url = string.format("https://%s/webchatv5/#/%s?signedParams=%s&signedCustomData=%s", domain, appId, signedParamsEncrypts, customData)
    CS.DeviceUtil.OpenURLNew(url)
  elseif ChannelManager:IsChinaChannel() then
    CS.AIHelp.AIHelpSupport.Show(self.sEntryID)
    CS.AIHelp.AIHelpSupport.FetchUnreadMessageCount()
  else
    CS.AiHelpManager.Instance:ShowWithEntranceID(self.sEntryID)
    CS.AiHelpManager.Instance:AiHelpGetUnReadMessageCount()
  end
end

function SettingManager:PullAiHelpMessage(sEntryID)
  self.sEntryID = sEntryID
  self:OnReadElvaMessage_CS()
end

function SettingManager:GetisEnterHallInLogin()
  return self.isEnterHallInLogin
end

function SettingManager:SetEnterHallInLogin(value)
  self.isEnterHallInLogin = value
end

function SettingManager:GetUrlWithLanguageId(commonTextId)
  local urlString = ""
  local urlListAll = {}
  local allUrlString = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(commonTextId).m_mMessage
  local urlList = string.split(allUrlString, ";")
  for i = 1, #urlList do
    local urlListTemp = string.split(urlList[i], "|")
    if 1 < #urlListTemp then
      local key = tonumber(urlListTemp[1])
      local value = urlListTemp[2]
      urlListAll[key] = value
    end
  end
  urlString = urlListAll[10]
  local iLangId = CS.MultiLanguageManager.g_iLanguageID
  if urlListAll[iLangId] then
    urlString = urlListAll[iLangId]
  end
  return urlString
end

function SettingManager:GetisEnterCastleInHall()
  return self.isEnterCastleInHall
end

function SettingManager:SetEnterCastleInHall(value)
  self.isEnterCastleInHall = value
end

function SettingManager:GetAiHelpCanIdentifyLanguage(iLanguageID)
  local languageStr = CS.MultiLanguageManager.Instance:GetLanguageID(iLanguageID)
  if languageStr == "cn" then
    languageStr = "zh-CN"
  elseif languageStr == "tw" then
    languageStr = "zh-TW"
  elseif languageStr == "my1" or languageStr == "my2" then
    languageStr = "my"
  end
  return languageStr
end

return SettingManager
