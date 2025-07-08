local Form_PlayerCenterPop = class("Form_PlayerCenterPop", require("UI/UIFrames/Form_PlayerCenterPopUI"))

function Form_PlayerCenterPop:SetInitParam(param)
end

function Form_PlayerCenterPop:AfterInit()
  self.super.AfterInit(self)
end

function Form_PlayerCenterPop:CheckRegisterRedDot()
  self:RegisterOrUpdateRedDotItem(self.m_LoginCustomerService_redPoint, RedDotDefine.ModuleType.LoginCustomerService)
end

function Form_PlayerCenterPop:OnActive()
  self.m_isActive = true
  self:RefreshUI()
  self:AddEventListeners()
end

function Form_PlayerCenterPop:OnInactive()
  self.m_isActive = false
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_PlayerCenterPop:AddEventListeners()
  self:addEventListener("eMSDKEvent_AccountInfo", handler(self, self.RefreshAccountInfo))
end

function Form_PlayerCenterPop:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PlayerCenterPop:RefreshUI()
  if self.m_isActive == false then
    return
  end
  self.m_txt_id_num_Text.text = tostring(RoleManager:GetUID())
  local account = CS.MSDKLogin.Instance.Account
  self:RefreshAccountInfo()
  if not account then
    CS.MSDKLogin.Instance:GetAccountInfo(nil, nil)
  end
  self.m_itemGP:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.Google))
  self.m_itemFB:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.FB))
  self.m_itemYJ:SetActive(false)
  self.m_itemX:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.X))
  self.m_itemIOS:SetActive(SDKUtil.CheckIsShowLoginMode(SDKUtil.LoginMode.Apple))
end

function Form_PlayerCenterPop:RefreshAccountInfo()
  local account = CS.MSDKLogin.Instance.Account
  self:ShowGoogleAccountInfo(account)
  self:ShowFBAccountInfo(account)
  self:ShowAppleAccountInfo(account)
end

function Form_PlayerCenterPop:ShowGoogleAccountInfo(account)
  local userName
  if account then
    local gpInfo = account:getTPInfoGP()
    if gpInfo then
      userName = gpInfo.InfoEmail
    end
  end
  local hasBind = userName ~= nil
  self.m_txt_account_name_Text.text = userName
  self.m_txt_account_name:SetActive(hasBind)
  self.m_btn_BindGP:SetActive(not hasBind)
  self.m_btn_relieveGP_Button.interactable = hasBind
  self.m_img_icon_unconnectgg:SetActive(hasBind)
end

function Form_PlayerCenterPop:ShowFBAccountInfo(account)
  local userName
  if account then
    local gpInfo = account:getTPInfoFB()
    if gpInfo then
      userName = gpInfo.InfoEmail
    end
    if userName == "" then
      userName = gpInfo.InfoUserName
    end
  end
  local hasBind = userName ~= nil
  self.m_txt_fb_account_name_Text.text = userName
  self.m_txt_fb_account_name:SetActive(hasBind)
  self.m_btn_BindFB:SetActive(not hasBind)
  self.m_btn_relieveFB_Button.interactable = hasBind
  self.m_img_icon_unconnectfb:SetActive(hasBind)
end

function Form_PlayerCenterPop:ShowAppleAccountInfo(account)
  local userName
  if account then
    local appleInfo = account:getTPInfoApple()
    if appleInfo then
      userName = appleInfo.InfoEmail
      if userName == "" then
        userName = appleInfo.InfoNickName
      end
      if userName == "" then
        userName = appleInfo.InfoOpenId
      end
    end
  end
  local hasBind = userName ~= nil
  self.m_txt_IOS_account_name_Text.text = userName
  self.m_txt_IOS_account_name:SetActive(hasBind)
  self.m_btn_BindIOS:SetActive(not hasBind)
  self.m_btn_relieveIOS_Button.interactable = hasBind
  self.m_img_icon_unconnectIOS:SetActive(hasBind)
end

function Form_PlayerCenterPop:OnBtnlogoutClicked()
  local hasBindAccount = SDKUtil.HasBindingWithThirdParty()
  if hasBindAccount then
    self:DoSwitchAndRestartGame()
  else
    local params = {
      tipsID = 1134,
      func1 = handler(self, self.DoSwitchAndRestartGame)
    }
    utils.CheckAndPushCommonTips(params)
  end
end

function Form_PlayerCenterPop:DoSwitchAndRestartGame()
  StackPopup:Push(UIDefines.ID_FORM_PLAYERCENTERPOP2)
end

function Form_PlayerCenterPop:OnBtncancelClicked()
  self:CloseForm()
  StackPopup:Push(UIDefines.ID_FORM_PLAYERACCOUNTDELPOP)
end

function Form_PlayerCenterPop:OnBtnCloseClicked()
  self:CloseForm()
end

function Form_PlayerCenterPop:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_PlayerCenterPop:OnBtnBindGPClicked()
  SDKUtil.BindingWithThirdParty("GP", handler(self, self.RefreshUI))
end

function Form_PlayerCenterPop:OnBtnBindFBClicked()
  SDKUtil.BindingWithThirdParty("FB", handler(self, self.RefreshUI))
end

function Form_PlayerCenterPop:OnBtnrelieveGPClicked()
  SDKUtil.UnbindingWithThirdParty("GP", handler(self, self.RefreshUI))
end

function Form_PlayerCenterPop:OnBtnrelieveFBClicked()
  SDKUtil.UnbindingWithThirdParty("FB", handler(self, self.RefreshUI))
end

function Form_PlayerCenterPop:OnBtnBindIOSClicked()
  SDKUtil.BindingWithThirdParty("APPLE", handler(self, self.RefreshUI))
end

function Form_PlayerCenterPop:OnBtnrelieveIOSClicked()
  SDKUtil.UnbindingWithThirdParty("APPLE", handler(self, self.RefreshUI))
end

function Form_PlayerCenterPop:OnBtncustomerserverClicked()
  SettingManager:PullAiHelpMessage()
end

function Form_PlayerCenterPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PlayerCenterPop", Form_PlayerCenterPop)
return Form_PlayerCenterPop
