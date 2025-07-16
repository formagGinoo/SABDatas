local Form_PilotCodePop = class("Form_PilotCodePop", require("UI/UIFrames/Form_PilotCodePopUI"))

function Form_PilotCodePop:SetInitParam(param)
end

function Form_PilotCodePop:AfterInit()
  self.super.AfterInit(self)
end

function Form_PilotCodePop:OnActive()
  self.tParam = self.m_csui.m_param
  self.super.OnActive(self)
  self:RefreshUI()
end

function Form_PilotCodePop:OnInactive()
  self.super.OnInactive(self)
end

function Form_PilotCodePop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PilotCodePop:OnBtnReturnClicked()
  StackPopup:RemoveUIFromStack(self:GetID())
end

function Form_PilotCodePop:OnBtnacceptClicked()
  if self.tParam.type == "login" then
    SDKUtil.LoginWithTransferCode(self.m_inputfield_TMP_InputField.text, function(isSuccess, result)
      if isSuccess then
        if ChannelManager:IsChinaChannel() then
          CS.AIHelp.AIHelpSupport.ResetUserInfo()
        else
          CS.AiHelpManager.Instance:AiHelpResetUserInfo()
        end
        ApplicationManager:RestartGame()
        StackPopup:RemoveUIFromStack(self:GetID())
      end
    end)
  else
    StackPopup:RemoveUIFromStack(self:GetID())
  end
end

function Form_PilotCodePop:OnBtncopyClicked()
  UILuaHelper.CopyTextToClipboard(tostring(self.m_csui.m_param.transferCode))
  StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 20025)
end

function Form_PilotCodePop:RefreshUI()
  self.m_inputfield_TMP_InputField.text = self.tParam.transferCode or ""
  self.m_btn_copy:SetActive(self.tParam.type == "apply")
  self.m_csui.m_uiGameObject.transform:Find("pnl_name/c_txt_inputtips").gameObject:SetActive(false)
  self.m_btn_accept:SetActive(self.tParam.type == "login")
end

local fullscreen = true
ActiveLuaUI("Form_PilotCodePop", Form_PilotCodePop)
return Form_PilotCodePop
