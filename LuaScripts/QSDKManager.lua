local BaseManager = require("Manager/Base/BaseManager")
local QSDKManager = class("QSDKManager", BaseManager)
local QSdkWindowsClient = require("Manager/QSDKWindowsClient")

function QSDKManager:OnCreate()
  self.m_dt = 1
end

function QSDKManager:OnUpdate(dt)
  self.m_dt = self.m_dt - dt
  if self.m_dt <= 0 then
    self.m_dt = 1
    self:CheckAntiAddiction()
  end
end

function QSDKManager:RegisterEvent()
  if ChannelManager:IsWindows() then
    return
  end
  CS.QSDKUtils.Instance:RegisterEvent(handler(self, self.OnSwitchAccountCB), handler(self, self.OnLogoutCB))
end

function QSDKManager:Initialize(OnInitSuccessCB, OnInitFailCB)
  if ChannelManager:IsWindows() then
    self.m_qSdkWindowsClient = QSdkWindowsClient.new()
    self.m_qSdkWindowsClient:Initialize(OnInitSuccessCB)
  else
    CS.QSDKUtils.Instance:Initialize(OnInitSuccessCB, OnInitFailCB)
  end
end

function QSDKManager:Login(OnLoginSuccessCB, OnLoginFailCB)
  if ChannelManager:IsWindows() then
    self.m_qSdkWindowsClient:Login(OnLoginSuccessCB, OnLoginFailCB)
  else
    CS.QSDKUtils.Instance:Login(function(userData)
      self.m_loginSuccess = true
      if OnLoginSuccessCB then
        OnLoginSuccessCB(userData)
      end
    end, OnLoginFailCB)
  end
end

function QSDKManager:Logout()
  CS.QSDKUtils.Instance:Logout()
end

function QSDKManager:Exit()
  if self:GetParentChannelType() == "134" and not self.m_loginSuccess then
    return
  end
  CS.QSDKUtils.Instance:Exit()
end

function QSDKManager:SetAccountInfo(accountInfo)
  self.m_accountInfo = accountInfo
end

function QSDKManager:GetAccountInfo()
  return self.m_accountInfo
end

function QSDKManager:ShowUserCenter()
end

function QSDKManager:ShowLicense()
  local urlString
  if self:IsSandBox() then
    urlString = "http://sdkapi.sandbox.yyf.moontonapp.com/agreement/read/id/11110.html"
  else
    urlString = "https://sdkapi.yyf.muyinetwork.com/agreement/read/id/11112.html"
  end
  StackPopup:Push(UIDefines.ID_FORM_WEBVIEWFULLSCREEN, {
    url = urlString,
    isShowTop = true,
    titleTxt = "用户协议",
    returnTxt = "返回",
    closeClass = "QSDKManager",
    closeFunc = "OnWebVeiwCloseCb"
  })
end

function QSDKManager:ShowPrivacyPolicy()
  local urlString
  if self:IsSandBox() then
    urlString = "http://sdkapi.sandbox.yyf.moontonapp.com/agreement/privacy/id/11110.html"
  else
    urlString = "https://sdkapi.yyf.muyinetwork.com/agreement/privacy/id/11112.html"
  end
  StackPopup:Push(UIDefines.ID_FORM_WEBVIEWFULLSCREEN, {
    url = urlString,
    isShowTop = true,
    titleTxt = "隐私协议",
    returnTxt = "返回",
    closeClass = "QSDKManager",
    closeFunc = "OnWebVeiwCloseCb"
  })
end

function QSDKManager:OnSwitchAccountCB(userInfo)
  CS.ApplicationManager.Instance:RestartGame()
end

function QSDKManager:OnLogoutCB()
  CS.ApplicationManager.Instance:RestartGame()
end

function QSDKManager:GetOaid()
  if ChannelManager:IsWindows() then
    return ""
  else
    return CS.QSDKUtils.Instance:GetOaid()
  end
end

function QSDKManager:CreateRoleBaseInfo()
  local roleInfo = {}
  roleInfo.serverID = UserDataManager:GetZoneID()
  roleInfo.serverName = UserDataManager:GetZoneName()
  roleInfo.gameRoleName = RoleManager:GetName()
  roleInfo.gameRoleID = RoleManager:GetUID()
  roleInfo.gameRoleBalance = "0"
  roleInfo.vipLevel = "0"
  roleInfo.gameRoleLevel = RoleManager:GetLevel()
  local allianceName = RoleManager:GetAllianceName()
  if allianceName == "" then
    allianceName = "default"
  end
  roleInfo.partyName = allianceName
  roleInfo.roleCreateTime = RoleManager:GetRoleRegTime()
  roleInfo.gameRoleGender = "未知"
  roleInfo.gameRolePower = "0"
  local iAllianceId = RoleManager:GetRoleAllianceInfo()
  roleInfo.partyId = iAllianceId or "default"
  roleInfo.professionId = "0"
  roleInfo.profession = "default"
  roleInfo.partyRoleId = "0"
  roleInfo.partyRoleName = "default"
  roleInfo.friendlist = "default"
  return roleInfo
end

function QSDKManager:CreateRole()
  if ChannelManager:IsWindows() then
    self.m_qSdkWindowsClient:CreateRole(QSDKManager:CreateRoleBaseInfo())
  else
    CS.QSDKUtils.Instance:CreateRole(QSDKManager:CreateRoleBaseInfo())
  end
end

function QSDKManager:EnterGame()
  if ChannelManager:IsWindows() then
    self.m_qSdkWindowsClient:EnterGame(QSDKManager:CreateRoleBaseInfo())
  else
    CS.QSDKUtils.Instance:EnterGame(QSDKManager:CreateRoleBaseInfo())
  end
end

function QSDKManager:UpdateRole()
  if ChannelManager:IsWindows() then
    self.m_qSdkWindowsClient:UpdateRole(QSDKManager:CreateRoleBaseInfo())
  else
    CS.QSDKUtils.Instance:UpdateRole(QSDKManager:CreateRoleBaseInfo())
  end
end

function QSDKManager:Pay(productID, productSubID, exParam, price, OnPayCB)
  if exParam == nil then
    exParam = {}
  end
  local orderInfo = {}
  orderInfo.goodsID = productID
  orderInfo.goodsName = exParam.productName or ""
  orderInfo.goodsDesc = exParam.productDesc or ""
  orderInfo.quantifier = "个"
  local vCreateRoleBaseInfo = QSDKManager:CreateRoleBaseInfo()
  local vExtrasParams = {}
  vExtrasParams.RoleId = vCreateRoleBaseInfo.gameRoleID
  vExtrasParams.ZoneId = vCreateRoleBaseInfo.serverID
  vExtrasParams.ProductId = productID
  if productSubID == nil or productSubID == "" then
    vExtrasParams.SubProductId = "0"
  end
  vExtrasParams.SubProductId = productSubID
  local strExtrasParams = ""
  for k, v in pairs(vExtrasParams) do
    strExtrasParams = strExtrasParams .. k .. "," .. v .. ";"
  end
  orderInfo.extrasParams = strExtrasParams
  orderInfo.count = 1
  orderInfo.amount = price
  orderInfo.price = price
  orderInfo.callbackUrl = ""
  orderInfo.cpOrderID = exParam.cpOrderID
  if ChannelManager:IsWindows() then
    return self.m_qSdkWindowsClient:Pay(orderInfo, vCreateRoleBaseInfo, OnPayCB)
  else
    return CS.QSDKUtils.Instance:Pay(orderInfo, vCreateRoleBaseInfo, OnPayCB)
  end
end

function QSDKManager:OnWebVeiwCloseCb()
  if ChannelManager:IsWindows() then
    self.m_qSdkWindowsClient:CloseWebView()
  else
    self:broadcastEvent("eGameEvent_Colse_UniWebView")
  end
end

function QSDKManager:SetMiscData(data)
end

function QSDKManager:CheckAntiAddiction()
  if self.m_logoutTime ~= nil and TimeUtil:GetServerTimeS() >= self.m_logoutTime then
    utils.CheckAndPushCommonTips({
      tipsID = 1125,
      bLockBack = true,
      func1 = function()
        CS.ApplicationManager.Instance:RestartGame()
      end
    })
    TimeService:SetTimer(3, 1, function()
      CS.ApplicationManager.Instance:RestartGame()
    end)
    self.m_logoutTime = nil
    return true
  end
  return false
end

function QSDKManager:CheckAntiAddictionNeedShowTips()
  if self.m_logoutTime ~= nil and self.m_logoutTime > TimeUtil:GetServerTimeS() then
    return true
  end
  return false
end

function QSDKManager:IsSandBox()
  if self.m_isSandbox == nil then
    self.m_isSandbox = ChannelManager:GetContext():IsQSDKSandBox()
  end
  return self.m_isSandbox
end

function QSDKManager:IsFunctionSupport(funcId)
  return CS.QSDKUtils.Instance:IsFunctionSupport(funcId)
end

function QSDKManager:CallFunction(successCB, failCB, funcId)
  return CS.QSDKUtils.Instance:CallFunction(successCB, failCB, funcId)
end

function QSDKManager:GetChannelType()
  if ChannelManager:IsWindows() then
    return self.m_qSdkWindowsClient:GetChannelType()
  else
    return tostring(CS.QSDKUtils.Instance:GetChannelType())
  end
end

function QSDKManager:GetParentChannelType()
  if ChannelManager:IsWindows() then
    return self.m_qSdkWindowsClient:GetParentChannelType()
  else
    return CS.QSDKUtils.Instance:GetParentChannelType()
  end
end

function QSDKManager:GetSubChannelCode()
  if not ChannelManager:IsWindows() and self:IsFunctionSupport(0) then
    return self:CallFunction(nil, nil, 0)
  end
  return ""
end

function QSDKManager:GetPackageChannel(sChannel)
  if self:GetParentChannelType() == "114" then
    return "and_cn_bili"
  end
  if self:GetParentChannelType() ~= "134" then
    return "and_cn_channel"
  end
  return sChannel
end

function QSDKManager:ReportReYunEvent(eventName, params)
  if ChannelManager:IsWindows() then
    return
  end
  local csharpDict
  if params ~= nil then
    csharpDict = CS.System.Collections.Generic.Dictionary(CS.System.String, CS.System.Object)()
    for k, v in pairs(params) do
      csharpDict[k] = v
    end
  end
  CS.QSDKUtils.Instance:ReportReYunEvent(eventName, csharpDict)
end

function QSDKManager:IsHuawei()
  return self:GetParentChannelType() == "24"
end

return QSDKManager
