local BaseObject = require("Base/BaseObject")
local QSDKWindowsClient = class("QSDKWindowsClient", BaseObject)
local EventCenter = require("events/EventCenter")
local EventDefine = require("events/EventDefine")

local function parse_query(query)
  local params = {}
  for key, value in string.gmatch(query, "([^&=?]+)=([^&]*)") do
    key = string.urldecode(key)
    value = string.urldecode(value)
    params[key] = value
  end
  return params
end

local function sort_params(params)
  local keys = {}
  for key, _ in pairs(params) do
    table.insert(keys, key)
  end
  table.sort(keys)
  return keys
end

local function build_signature_string(params)
  local keys = sort_params(params)
  local result = {}
  for _, key in ipairs(keys) do
    if key ~= "sign" then
      table.insert(result, key .. "=" .. params[key])
    end
  end
  return table.concat(result, "&")
end

function QSDKWindowsClient:Initialize(successCB)
  self.m_openid = "XGWNhT"
  self.m_openKey = "M8gE3h5hhAEAk7wURMPNmIde5bV1YdUL"
  self.m_productCode = "47307270774782153075014942885550"
  self.m_successUrl = "http://47.101.215.195:8095/loginSuccess"
  self.m_cancelUrl = "http://47.101.215.195:8095/loginCancel"
  self.m_paySuccessUrl = "http://47.101.215.195:8095/paySuccess"
  self.m_payCancelUrl = "http://47.101.215.195:8095/payCancel"
  self.m_payCheckoutUrl = "payStatusCheck/stop"
  if self:IsSandBox() then
    self.m_baseUrl = "http://sdkapi.sandbox.yyf.moontonapp.com"
  else
    self.m_baseUrl = "http://sdkapi.yyf.muyinetwork.com"
  end
  if successCB then
    successCB()
  end
  EventCenter.AddListener(EventDefine.eGameEvent_IAPDelivery_Push, handler(self, self.OnPushIAPDelivery))
end

function QSDKWindowsClient:GenerateSign(params, openKey)
  local stringA = build_signature_string(params)
  local stringB = stringA .. "&" .. openKey
  return CS.Util.md5fileByMemory(stringB)
end

function QSDKWindowsClient:IsSandBox()
  return true
end

function QSDKWindowsClient:Login(OnLoginSuccessCB, OnLoginFailCB)
  self.m_OnLoginSuccessCB = OnLoginSuccessCB
  self.m_OnLoginFailCB = OnLoginFailCB
  local urlString = self.m_baseUrl .. "/open/oauth"
  self.m_accountInfo = {}
  urlString = urlString .. "?openId=" .. self.m_openid
  urlString = urlString .. "&productCode=" .. self.m_productCode
  urlString = urlString .. "&channelCode=" .. self:GetChannelType()
  urlString = urlString .. "&successUrl=" .. self.m_successUrl
  if self.m_cancelUrl ~= "" then
    urlString = urlString .. "&cancelUrl=" .. self.m_cancelUrl
  end
  urlString = urlString .. "&theme=novaGame"
  urlString = urlString .. "&stopClose=1"
  log.info("url:" .. urlString)
  StackPopup:Push(UIDefines.ID_FORM_WEBVIEWFULLSCREEN, {
    url = urlString,
    isShowTop = false,
    closeClass = "QSDKManager",
    closeFunc = "OnWebVeiwCloseCb",
    urlChangedCb = handler(self, self.OnUrlChangedCb),
    width = 470,
    height = 475
  })
end

function QSDKWindowsClient:CloseWebView()
  EventCenter.Broadcast(EventDefine.eGameEvent_Colse_UniWebView)
end

function QSDKWindowsClient:OnUrlChangedCb(changedUrl)
  if not string.find(changedUrl, self.m_baseUrl) then
    if string.find(changedUrl, self.m_successUrl) then
      local params = parse_query(changedUrl)
      self.m_accountInfo.uid = params.uid
      self.m_accountInfo.username = params.username
      self.m_accountInfo.token = params.authToken
      if self.m_OnLoginSuccessCB then
        self.m_OnLoginSuccessCB(self.m_accountInfo)
      end
    elseif string.find(changedUrl, self.m_cancelUrl) then
      if self.m_OnLoginFailCB then
        self.m_OnLoginFailCB()
      end
    elseif string.find(changedUrl, self.m_paySuccessUrl) then
      log.info("支付成功")
      if self.m_OnPayCB then
        self.m_OnPayCB(0)
      end
    elseif string.find(changedUrl, self.m_payCancelUrl) then
      log.info("支付取消")
      if self.m_OnPayCB then
        self.m_OnPayCB(-1)
      end
    end
    self:CloseWebView()
  elseif string.find(changedUrl, self.m_payCheckoutUrl) then
    log.info("支付校验")
    if self.m_OnPayCB then
      self.m_OnPayCB(-1)
    end
    self:CloseWebView()
  end
  log.info("QSDKWindowsClient:OnUrlChangedCb:" .. changedUrl)
end

function QSDKWindowsClient:verifyToken(params)
  local url = self.m_baseUrl .. "/webOpen/checkToken"
  local postParams = {}
  postParams.openId = self.m_openid
  postParams.productCode = self.m_productCode
  postParams.authToken = params.authToken
  postParams.sign = self:GenerateSign(postParams, self.m_openKey)
  Util.DoHttpPost(url, postParams, function(isSuccess, message)
    if isSuccess then
      local retTable = json.decode(message)
      if retTable.status == true and retTable.data ~= nil then
        self.m_accountInfo.token = retTable.data.token
        if self.m_OnLoginSuccessCB then
          self.m_OnLoginSuccessCB(self.m_accountInfo)
        end
      elseif self.m_OnLoginFailCB then
        self.m_OnLoginFailCB()
      end
    elseif self.m_OnLoginFailCB then
      self.m_OnLoginFailCB()
    end
    log.info("verifyToken isSuccess:" .. tostring(isSuccess) .. ", message:" .. tostring(message))
  end)
end

function QSDKWindowsClient:Logout(OnLogoutCB)
end

function QSDKWindowsClient:ShowUserCenter()
  local urlString = self.m_baseUrl .. "/openCenter/index"
  urlString = urlString .. "?appProduct=" .. self.m_productCode
  urlString = urlString .. "&channelCode=" .. self:GetChannelType()
  urlString = urlString .. "&authToken=" .. self.m_accountInfo.token
  StackPopup:Push(UIDefines.ID_FORM_WEBVIEWFULLSCREEN, {
    url = urlString,
    isShowTop = false,
    closeClass = "QSDKManager",
    closeFunc = "OnWebVeiwCloseCb",
    urlChangedCb = handler(self, self.OnUrlChangedCb),
    width = 470,
    height = 475
  })
end

function QSDKWindowsClient:UpdateRoleInfo(params)
  local url = self.m_baseUrl .. "/webOpen/setGameRoleInfo"
  local postParams = {}
  postParams.openId = self.m_openid
  postParams.productCode = self.m_productCode
  postParams.channelCode = self:GetChannelType()
  postParams.userId = self.m_accountInfo.uid
  postParams.vipLevel = params.vipLevel
  postParams.deviceId = "Nova12345678"
  postParams.partyId = params.partyId
  postParams.partyName = params.partyName
  postParams.userRoleName = params.gameRoleName
  postParams.userRoleLevel = params.gameRoleLevel
  postParams.userRoleBalance = params.gameRoleBalance
  postParams.userRoleId = params.gameRoleID
  postParams.serverId = params.serverID
  postParams.serverName = params.serverName
  postParams.sign = self:GenerateSign(postParams, self.m_openKey)
  Util.DoHttpPost(url, postParams, function(isSuccess, message)
    log.info("UpdateRoleInfo isSuccess:" .. tostring(isSuccess) .. ", message:" .. tostring(message))
  end)
end

function QSDKWindowsClient:CreateRole(params)
  self:UpdateRoleInfo(params)
end

function QSDKWindowsClient:EnterGame(params)
  self:UpdateRoleInfo(params)
end

function QSDKWindowsClient:UpdateRole(params)
  self:UpdateRoleInfo(params)
end

function QSDKWindowsClient:Pay(orderInfo, roleBaseInfo, OnPayCB)
  self.m_OnPayCB = OnPayCB
  local url = self.m_baseUrl .. "/webOpen/getPayUrl"
  local postParams = {}
  postParams.openId = self.m_openid
  postParams.productCode = self.m_productCode
  postParams.channelCode = self:GetChannelType()
  postParams.amount = orderInfo.amount
  postParams.userId = self.m_accountInfo.uid
  postParams.cpOrderNo = orderInfo.cpOrderID
  postParams.orderSubject = orderInfo.goodsDesc
  postParams.goodsName = orderInfo.goodsName
  postParams.roleName = roleBaseInfo.gameRoleName
  postParams.roleLevel = roleBaseInfo.gameRoleLevel
  postParams.serverId = roleBaseInfo.serverID
  postParams.serverName = roleBaseInfo.serverName
  postParams.extrasParams = orderInfo.extrasParams
  postParams.successUrl = self.m_paySuccessUrl
  postParams.cancelUrl = self.m_payCancelUrl
  postParams.sign = self:GenerateSign(postParams, self.m_openKey)
  postParams.theme = "novaGame"
  Util.DoHttpPost(url, postParams, function(isSuccess, message)
    if isSuccess then
      local retTable = json.decode(message)
      if retTable.status == true and retTable.data ~= nil then
        local urlString = "http://" .. retTable.data.payUrl
        StackPopup:Push(UIDefines.ID_FORM_WEBVIEWFULLSCREEN, {
          url = urlString,
          isShowTop = false,
          closeClass = "QSDKManager",
          closeFunc = "OnWebVeiwCloseCb",
          urlChangedCb = handler(self, self.OnUrlChangedCb),
          width = 470,
          height = 475
        })
      elseif OnPayCB then
        OnPayCB(-2)
      end
    elseif OnPayCB then
      OnPayCB(-2)
    end
    log.info("Pay isSuccess:" .. tostring(isSuccess) .. ", message:" .. tostring(message))
  end)
end

function QSDKWindowsClient:GetChannelType()
  return "134"
end

function QSDKWindowsClient:GetParentChannelType()
  return "134"
end

function QSDKWindowsClient:OnPushIAPDelivery()
  if self.m_OnPayCB then
    self.m_OnPayCB(0)
  end
  self:CloseWebView()
end

return QSDKWindowsClient
