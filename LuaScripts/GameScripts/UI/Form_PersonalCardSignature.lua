local Form_PersonalCardSignature = class("Form_PersonalCardSignature", require("UI/UIFrames/Form_PersonalCardSignatureUI"))

function Form_PersonalCardSignature:SetInitParam(param)
end

function Form_PersonalCardSignature:AfterInit()
  self.super.AfterInit(self)
  self.m_inputfield_InputField.onEndEdit:AddListener(function()
    self:CheckStrIsCorrect()
  end)
  self.m_inputfield_InputField.onValueChanged:AddListener(function()
    self:OnValueChangedRefresh()
  end)
end

function Form_PersonalCardSignature:OnActive()
  self.super.OnActive(self)
  self:AddEventListeners()
end

function Form_PersonalCardSignature:OnInactive()
  self.super.OnInactive(self)
  self:RemoveAllEventListeners()
end

function Form_PersonalCardSignature:AddEventListeners()
  self:addEventListener("eGameEvent_Role_SetSignature", handler(self, self.OnBtnCloseClicked))
end

function Form_PersonalCardSignature:RemoveAllEventListeners()
  self:clearEventListener()
end

function Form_PersonalCardSignature:OnValueChangedRefresh()
  self:RefreshStrNum()
  self:CheckStrIsCorrect()
end

function Form_PersonalCardSignature:RefreshStrNum()
  local num = string.utf8len_WordCount(self.m_inputfield_InputField.text)
  self.m_txt_notice_max_Text.text = num .. "/50"
  if 50 < num then
    UILuaHelper.SetColor(self.m_txt_notice_max_Text, 142, 38, 38, 200)
  else
    UILuaHelper.SetColor(self.m_txt_notice_max_Text, 0, 0, 0, 200)
  end
end

function Form_PersonalCardSignature:CheckStrIsCorrect()
  local text = self.m_inputfield_InputField.text
  if text ~= "" then
    local str = string.GetTextualNormsGuildNotice(text)
    self.m_inputfield_InputField.text = str
  end
end

function Form_PersonalCardSignature:OnBtnsaveClicked()
  local text = self.m_inputfield_InputField.text
  local spacing = string.checkFirstCharIsSpacing(text)
  if spacing then
    StackPopup:Push(UIDefines.ID_FORM_COMMON_TOAST, 30020)
    return
  end
  RoleManager:ReqSetSignatureCS(text)
end

function Form_PersonalCardSignature:OnBtnemptyClicked()
  self:OnBtnCloseClicked()
end

function Form_PersonalCardSignature:OnBtnReturnClicked()
  self:OnBtnCloseClicked()
end

function Form_PersonalCardSignature:IsOpenGuassianBlur()
  return true
end

function Form_PersonalCardSignature:OnBtnCloseClicked()
  StackPopup:RemoveUIFromStack(UIDefines.ID_FORM_PERSONALCARDSIGNATURE)
end

function Form_PersonalCardSignature:OnDestroy()
  self.super.OnDestroy(self)
  self:RemoveAllEventListeners()
end

local fullscreen = true
ActiveLuaUI("Form_PersonalCardSignature", Form_PersonalCardSignature)
return Form_PersonalCardSignature
