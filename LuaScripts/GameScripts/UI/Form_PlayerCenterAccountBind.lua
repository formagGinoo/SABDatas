local Form_PlayerCenterAccountBind = class("Form_PlayerCenterAccountBind", require("UI/UIFrames/Form_PlayerCenterAccountBindUI"))

function Form_PlayerCenterAccountBind:AfterInit()
  self.super.AfterInit(self)
end

function Form_PlayerCenterAccountBind:OnActive()
  self.super.OnActive(self)
  self.m_csui.m_uiGameObject.transform:Find("ui_common_frame_middle/img_txt_bg/txt_frame_middle_title"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("PlayerCenterAccountBindTitle")
  self.m_csui.m_uiGameObject.transform:Find("txt_word"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("PlayerCenterAccountBindDesc")
  self.m_btn_facebook.transform:Find("txt_facebook"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("PlayerCenterAccountBindFacebook")
  self.m_btn_sign.transform:Find("txt_sign_desc1"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("PlayerCenterAccountBindGoogle")
  self.m_btn_appleid.transform:Find("txt_appleid"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("PlayerCenterAccountBindAppleID")
  self.m_btn_notsign.transform:Find("txt_sign_desc2"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("PlayerCenterAccountBindGuest")
  self.onCloseCallBack = self.m_csui.m_param
  self.m_btn_sign:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.Google))
  self.m_btn_facebook:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.Facebook))
  self.m_btn_appleid:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.Apple))
  local account = CS.MSDKLogin.Instance.Account
  local reportData = {
    account = account.accountID or "null",
    event = "open"
  }
  ReportManager:ReportAccountBindStep(reportData)
end

function Form_PlayerCenterAccountBind:OnBtnsignClicked()
  SDKUtil.BindingWithThirdParty("GP", function(isSuccess)
    if isSuccess then
      self:Close(0)
      local account = CS.MSDKLogin.Instance.Account
      local reportData = {
        account = account.accountID or "null",
        event = "success"
      }
      ReportManager:ReportAccountBindStep(reportData)
    else
      local account = CS.MSDKLogin.Instance.Account
      local reportData = {
        account = account.accountID or "null",
        event = "fail"
      }
      ReportManager:ReportAccountBindStep(reportData)
    end
  end)
end

function Form_PlayerCenterAccountBind:OnBtnfacebookClicked()
  SDKUtil.BindingWithThirdParty("FB", function(isSuccess)
    if isSuccess then
      self:Close(0)
      local account = CS.MSDKLogin.Instance.Account
      local reportData = {
        account = account.accountID or "null",
        event = "success"
      }
      ReportManager:ReportAccountBindStep(reportData)
    else
      local account = CS.MSDKLogin.Instance.Account
      local reportData = {
        account = account.accountID or "null",
        event = "fail"
      }
      ReportManager:ReportAccountBindStep(reportData)
    end
  end)
end

function Form_PlayerCenterAccountBind:OnBtnappleidClicked()
  SDKUtil.BindingWithThirdParty("APPLE", function(isSuccess)
    if isSuccess then
      self:Close(0)
      local account = CS.MSDKLogin.Instance.Account
      local reportData = {
        account = account.accountID or "null",
        event = "success"
      }
      ReportManager:ReportAccountBindStep(reportData)
    else
      local account = CS.MSDKLogin.Instance.Account
      local reportData = {
        account = account.accountID or "null",
        event = "fail"
      }
      ReportManager:ReportAccountBindStep(reportData)
    end
  end)
end

function Form_PlayerCenterAccountBind:OnBtnnotsignClicked()
  self:Close(1)
  local account = CS.MSDKLogin.Instance.Account
  local reportData = {
    account = account.accountID or "null",
    event = "success"
  }
  ReportManager:ReportAccountBindStep(reportData)
end

function Form_PlayerCenterAccountBind:OnBtnReturnClicked()
  self:Close(2)
  local account = CS.MSDKLogin.Instance.Account
  local reportData = {
    account = account.accountID or "null",
    event = "cancel"
  }
  ReportManager:ReportAccountBindStep(reportData)
end

function Form_PlayerCenterAccountBind:OnBtnCloseClicked()
  self:Close(2)
  local account = CS.MSDKLogin.Instance.Account
  local reportData = {
    account = account.accountID or "null",
    event = "close"
  }
  ReportManager:ReportAccountBindStep(reportData)
end

function Form_PlayerCenterAccountBind:IsOpenGuassianBlur()
  return true
end

function Form_PlayerCenterAccountBind:Close(opType)
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PLAYERCENTERACCOUNTBIND)
  if self.onCloseCallBack then
    self.onCloseCallBack(opType)
  end
end

ActiveLuaUI("Form_PlayerCenterAccountBind", Form_PlayerCenterAccountBind)
return Form_PlayerCenterAccountBind
