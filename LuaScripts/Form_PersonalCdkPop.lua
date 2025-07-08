local Form_PersonalCdkPop = class("Form_PersonalCdkPop", require("UI/UIFrames/Form_PersonalCdkPopUI"))

function Form_PersonalCdkPop:SetInitParam(param)
end

function Form_PersonalCdkPop:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_TMP_InputField.onEndEdit:AddListener(function()
  end)
  self.m_inputfield_TMP_InputField.onValueChanged:AddListener(function(input)
    self.m_inputfield_TMP_InputField.text = string.upper(input)
  end)
end

function Form_PersonalCdkPop:OnActive()
  self.super.OnActive(self)
end

function Form_PersonalCdkPop:OnInactive()
  self.super.OnInactive(self)
end

function Form_PersonalCdkPop:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_PersonalCdkPop:OnNodelightClicked()
  if self.m_inputfield_TMP_InputField.text == "" then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, ConfigManager:GetClientMessageTextById(45014))
    return
  end
  local exchangeCDKMsg = MTTDProto.Cmd_Role_ExchangeCDKey_CS()
  exchangeCDKMsg.sCDKey = self.m_inputfield_TMP_InputField.text
  RPCS():Role_ExchangeCDKey(exchangeCDKMsg, function()
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40022)
    self.m_inputfield_TMP_InputField.text = ""
  end, function()
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 40023)
    self.m_inputfield_TMP_InputField.text = ""
  end)
end

function Form_PersonalCdkPop:OnBtnCloseClicked()
  StackFlow:RemoveUIFromStack(self:GetID())
end

function Form_PersonalCdkPop:OnBtnReturnClicked()
  StackFlow:RemoveUIFromStack(self:GetID())
end

function Form_PersonalCdkPop:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_PersonalCdkPop", Form_PersonalCdkPop)
return Form_PersonalCdkPop
