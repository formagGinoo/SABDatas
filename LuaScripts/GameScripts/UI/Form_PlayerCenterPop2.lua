local Form_PlayerCenterPop2 = class("Form_PlayerCenterPop2", require("UI/UIFrames/Form_PlayerCenterPop2UI"))

function Form_PlayerCenterPop2:SetInitParam(param)
end

function Form_PlayerCenterPop2:AfterInit()
  self.super.AfterInit(self)
end

function Form_PlayerCenterPop2:OnActive()
  self.super.OnActive(self)
  self:FreshText()
  self:RefreshView()
end

function Form_PlayerCenterPop2:OnInactive()
  self.super.OnInactive(self)
end

function Form_PlayerCenterPop2:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PlayerCenterPop2:RefreshView()
  local account = CS.MSDKLogin.Instance.Account
  if account then
    local gpInfo = account:getTPInfoGP()
    if gpInfo then
      self.m_icon_account.gameObject:SetActive(true)
      self.m_txt_account_name_Text.text = gpInfo.InfoEmail
      UILuaHelper.SetAtlasSprite(self.m_icon_account_Image, "Atlas_Login/account_icon_google")
    end
    local fbInfo = account:getTPInfoFB()
    if fbInfo then
      self.m_icon_account.gameObject:SetActive(true)
      if fbInfo.InfoEmail and fbInfo.InfoEmail ~= "" then
        self.m_txt_account_name_Text.text = fbInfo.InfoEmail
      else
        self.m_txt_account_name_Text.text = fbInfo.InfoUserName
      end
      UILuaHelper.SetAtlasSprite(self.m_icon_account_Image, "Atlas_Login/account_icon_facebook")
    end
    local appleInfo = account:getTPInfoApple()
    if appleInfo then
      self.m_icon_account.gameObject:SetActive(true)
      if appleInfo.InfoEmail and appleInfo.InfoEmail ~= "" then
        self.m_txt_account_name_Text.text = appleInfo.InfoEmail
      else
        self.m_txt_account_name_Text.text = appleInfo.InfoNickName
      end
      UILuaHelper.SetAtlasSprite(self.m_icon_account_Image, "Atlas_Login/account_icon_apple")
    end
  end
  self.m_icon_account.gameObject:SetActive(false)
  local roleName = RoleManager:GetName() or ""
  self.m_txt_account_name_Text.text = roleName
  self.m_btn_google:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.Google))
  self.m_btn_facebook:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.FB))
  self.m_btn_appleid:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.Apple))
end

function Form_PlayerCenterPop2:OnBtngoogleClicked()
  self:OnSwitchAccount("GP")
end

function Form_PlayerCenterPop2:OnBtnfacebookClicked()
  self:OnSwitchAccount("FB")
end

function Form_PlayerCenterPop2:OnBtnappleidClicked()
  self:OnSwitchAccount("APPLE")
end

function Form_PlayerCenterPop2:FreshText()
  self.m_csui.m_uiGameObject.transform:Find("ui_common_frame_middle/img_txt_bg/txt_frame_middle_title"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("Form_PlayerCenterPop2Title")
  self.m_csui.m_uiGameObject.transform:Find("pnl_item_account/txt_id_desc"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("Form_PlayerCenterPop2CurName")
  self.m_csui.m_uiGameObject.transform:Find("txt_otherway"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("Form_PlayerCenterPop2OtherWay")
  self.m_btn_google.transform:Find("txt_google"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("Form_PlayerCenterPop2Google")
  self.m_btn_facebook.transform:Find("txt_facebook"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("Form_PlayerCenterPop2FaceBook")
  self.m_btn_x.transform:Find("txt_x"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("Form_PlayerCenterPop2X")
  self.m_btn_appleid.transform:Find("txt_appleid"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("Form_PlayerCenterPop2AppleId")
  self.m_btn_email.transform:Find("txt_email"):GetComponent("TextPro").text = CS.ConfFact.LangFormat4DataInit("Form_PlayerCenterPop2Email")
end

function Form_PlayerCenterPop2:OnSwitchAccount(thirdParty)
  SDKUtil.LoginWithThirdParty(thirdParty, function(isSuccess)
    if isSuccess then
      if ChannelManager:IsChinaChannel() then
        CS.AIHelp.AIHelpSupport.ResetUserInfo()
      else
        CS.AiHelpManager.Instance:AiHelpResetUserInfo()
      end
      ApplicationManager:RestartGame()
    end
  end)
end

local fullscreen = true
ActiveLuaUI("Form_PlayerCenterPop2", Form_PlayerCenterPop2)
return Form_PlayerCenterPop2
