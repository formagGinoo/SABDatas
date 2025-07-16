local Form_PlayerCancelInforTips = class("Form_PlayerCancelInforTips", require("UI/UIFrames/Form_PlayerCancelInforTipsUI"))
local http = "http"

function Form_PlayerCancelInforTips:SetInitParam(param)
end

function Form_PlayerCancelInforTips:AfterInit()
  self.super.AfterInit(self)
  self.rootObj = self.m_csui.m_uiGameObject
end

function Form_PlayerCancelInforTips:OnActive()
  self.urlString = self.m_csui.m_param
  if not self.urlString then
    return
  end
  self.m_btn_yes.transform:Find("txt_yes"):GetComponent("TextMeshProUGUI").text = CS.ConfFact.LangFormat4DataInit("PlayerCancelInfoYes")
  self.m_btnClose:SetActive(true)
  local theFirst = string.sub(self.urlString, 1, 4)
  TimeService:SetTimer(0.05, 1, function()
    if theFirst ~= http then
      self.m_pnl_mask:SetActive(true)
      self.m_txt_title:SetActive(true)
      local txtArray = string.split(self.urlString, "|")
      self.m_txt_title_Text.text = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(tonumber(txtArray[1])).m_mMessage
      self.m_textContent_Text.text = ConfigManager:GetConfigInsByName("CommonText"):GetValue_ById(tonumber(txtArray[2])).m_mMessage
    else
      self.m_pnl_mask:SetActive(false)
      self.m_txt_title:SetActive(false)
      self.tempWebView = GameObject.Instantiate(self.m_webView, self.m_webViewRoot.transform)
      self.tempWebView.transform.localPosition = Vector2.zero
      UILuaHelper.SetWebView(self.tempWebView, self.urlString)
    end
  end)
end

function Form_PlayerCancelInforTips:OnInactive()
end

function Form_PlayerCancelInforTips:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PlayerCancelInforTips:OnBtnyesClicked()
  if self.tempWebView then
    GameObject.Destroy(self.tempWebView)
    self.tempWebView = nil
  end
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS)
end

function Form_PlayerCancelInforTips:OnBtnCloseClicked()
  if self.tempWebView then
    GameObject.Destroy(self.tempWebView)
    self.tempWebView = nil
  end
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PLAYERCANCELINFORTIPS)
end

function Form_PlayerCancelInforTips:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PlayerCancelInforTips", Form_PlayerCancelInforTips)
return Form_PlayerCancelInforTips
