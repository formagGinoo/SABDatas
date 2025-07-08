local Form_WebViewFullScreen = class("Form_WebViewFullScreen", require("UI/UIFrames/Form_WebViewFullScreenUI"))

function Form_WebViewFullScreen:SetInitParam(param)
end

function Form_WebViewFullScreen:AfterInit()
  self.super.AfterInit(self)
end

function Form_WebViewFullScreen:OnActive()
  self.super.OnActive(self)
  self:clearEventListener()
  self:AddEventListeners()
  local param = self.m_csui.m_param
  local urlString = param.url or ""
  local returnTxt = param.returnTxt
  if returnTxt == nil then
    returnTxt = ConfigManager:GetCommonTextById(20020) or ""
  end
  local titleTxt = param.titleTxt
  if titleTxt == nil then
    titleTxt = ConfigManager:GetCommonTextById(20019) or ""
  end
  local closeClass = param.closeClass or "ActivityManager"
  local closeFunc = param.closeFunc or "ColseFormWebViewFullScreen"
  self.tempWebView = GameObject.Instantiate(self.m_webView, self.m_WebViewRoot.transform)
  UILuaHelper.SetActive(self.m_webView, false)
  UILuaHelper.SetActive(self.tempWebView, true)
  self.tempWebView.transform.localPosition = Vector2.zero
  UILuaHelper.SetWebView(self.tempWebView, urlString, param.isShowTop == nil and true or param.isShowTop, returnTxt, titleTxt, closeClass, closeFunc, param.urlChangedCb, param.width or -1, param.height or -1)
end

function Form_WebViewFullScreen:AddEventListeners()
  self:addEventListener("eGameEvent_Colse_UniWebView", handler(self, self.OnCloseWebView))
end

function Form_WebViewFullScreen:OnCloseWebView()
  if self.tempWebView then
    GameObject.Destroy(self.tempWebView)
    self.tempWebView = nil
    self.uniWebView = nil
  end
  self:CloseForm()
end

function Form_WebViewFullScreen:OnInactive()
  self.super.OnInactive(self)
  if self.tempWebView then
    GameObject.Destroy(self.tempWebView)
    self.tempWebView = nil
    self.uniWebView = nil
  end
  self:clearEventListener()
end

function Form_WebViewFullScreen:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_WebViewFullScreen:OnCloseBtnClicked()
  self:OnCloseWebView()
end

local fullscreen = true
ActiveLuaUI("Form_WebViewFullScreen", Form_WebViewFullScreen)
return Form_WebViewFullScreen
