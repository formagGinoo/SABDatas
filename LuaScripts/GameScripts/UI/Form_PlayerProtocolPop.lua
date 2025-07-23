local Form_PlayerProtocolPop = class("Form_PlayerProtocolPop", require("UI/UIFrames/Form_PlayerProtocolPopUI"))

function Form_PlayerProtocolPop:SetInitParam(param)
end

function Form_PlayerProtocolPop:AfterInit()
  if ChannelManager:IsEUChannel() and not ChannelManager:IsWindows() then
    self.m_z_more:SetActive(true)
    self.m_z_more:GetComponent("ButtonExtensions").Clicked = handler(self, self.OnBtnMoreClicked)
    self.m_z_more_Text.text = CS.ConfFact.LangFormat4DataInit("CMPinformation")
  else
    self.m_z_more:SetActive(false)
  end
end

function Form_PlayerProtocolPop:OnActive()
  self:RefreshUI()
  self.onCloseCallBack = self.m_csui.m_param
  local account = CS.MSDKLogin.Instance.Account
  if account then
    local reportData = {
      account = account.accountID or "null",
      event = "open"
    }
    ReportManager:ReportLoginProtocolStep(reportData)
  end
end

function Form_PlayerProtocolPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_PlayerProtocolPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PlayerProtocolPop:RefreshUI()
  self.m_csui.m_uiGameObject.transform:Find("ui_common_frame_big/img_txt_bg/txt_frame_big_title"):GetComponent("TextMeshProUGUI").text = CS.ConfFact.LangFormat4DataInit("PlayerProtocolTitle")
  self.m_btn_yes.transform:Find("txt_yes"):GetComponent("TextMeshProUGUI").text = CS.ConfFact.LangFormat4DataInit("PlayerProtocolYes")
  self.m_btn_cancle.transform:Find("txt_upgrade_black"):GetComponent("TextMeshProUGUI").text = CS.ConfFact.LangFormat4DataInit("PlayerProtocolNo")
  self.m_textContent_Text.text = CS.ConfFact.LangFormat4DataInit("PlayerProtocolContent")
  self.m_toggle_txt_user_Text.text = CS.ConfFact.LangFormat4DataInit("PlayerUserToggle")
  self.m_toggle_txt_privacypolicy_Text.text = CS.ConfFact.LangFormat4DataInit("PlayerPrivacyToggle")
  if ChannelManager:IsUSChannel() then
    self.m_toggle_txt_user_Text.text = CS.ConfFact.LangFormat4DataInit("PlayerUserToggleUs")
    self.m_toggle_txt_privacypolicy_Text.text = CS.ConfFact.LangFormat4DataInit("PlayerPrivacyToggleUs")
  end
  if ChannelManager:IsDMMChannel() then
    self.m_toggle_txt_user_Text.text = CS.ConfFact.LangFormat4DataInit("PlayerUserToggleDMM")
    self.m_toggle_txt_privacypolicy_Text.text = CS.ConfFact.LangFormat4DataInit("PlayerPrivacyToggleDMM")
  end
  self.m_toggle_txt_ageagreement_Text.text = CS.ConfFact.LangFormat4DataInit("PlayerAgeToggle")
end

function Form_PlayerProtocolPop:OnBtnCloseClicked()
  local account = CS.MSDKLogin.Instance.Account
  if account then
    local reportData = {
      account = account.accountID or "null",
      event = "close"
    }
    ReportManager:ReportLoginProtocolStep(reportData)
  end
end

function Form_PlayerProtocolPop:OnBtnReturnClicked()
  CS.ApplicationManager.Instance:RestartGame()
  local account = CS.MSDKLogin.Instance.Account
  if account then
    local reportData = {
      account = account.accountID or "null",
      event = "cancle"
    }
    ReportManager:ReportLoginProtocolStep(reportData)
  end
end

function Form_PlayerProtocolPop:OnBtnyesClicked()
  if self.m_Toggle_ageagreement_Toggle.isOn ~= true or self.m_Toggle_privacypolicy_Toggle.isOn ~= true or self.m_Toggle_user_Toggle.isOn ~= true then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, CS.ConfFact.LangFormat4DataInit("PlayerProtocolConfirmWarning"))
    return
  else
    self:CloseUI()
  end
  if ChannelManager:IsEUChannel() and not ChannelManager:IsWindows() then
    CS.UserCentricsCtrl.Instance:AcceptAll()
  end
  local account = CS.MSDKLogin.Instance.Account
  if account then
    local reportData = {
      account = account.accountID or "null",
      event = "confirm"
    }
    ReportManager:ReportLoginProtocolStep(reportData)
  end
end

function Form_PlayerProtocolPop:OnBtnMoreClicked()
  CS.UserCentricsCtrl.Instance:ShowSecondLayer()
end

function Form_PlayerProtocolPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PlayerProtocolPop:CloseUI()
  local agree = false
  if self.m_Toggle_ageagreement_Toggle.isOn and self.m_Toggle_privacypolicy_Toggle.isOn and self.m_Toggle_user_Toggle.isOn then
    agree = true
  end
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PLAYERPROTOCOLPOP)
  if self.onCloseCallBack then
    self.onCloseCallBack(agree)
  end
end

function Form_PlayerProtocolPop:OnBtncancleClicked()
  if ChannelManager:IsEUChannel() and not ChannelManager:IsWindows() then
    CS.UserCentricsCtrl.Instance:AcceptAll()
  end
  self.m_Toggle_user_Toggle.isOn = true
  self.m_Toggle_privacypolicy_Toggle.isOn = true
  self.m_Toggle_ageagreement_Toggle.isOn = true
end

function Form_PlayerProtocolPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PlayerProtocolPop", Form_PlayerProtocolPop)
return Form_PlayerProtocolPop
