local Form_LoginAgePrompt = class("Form_LoginAgePrompt", require("UI/UIFrames/Form_LoginAgePromptUI"))
local ConfirmCommonTipsIns = ConfigManager:GetConfigInsByName("ConfirmCommonTips")

function Form_LoginAgePrompt:SetInitParam(param)
end

function Form_LoginAgePrompt:AfterInit()
  self.super.AfterInit(self)
end

function Form_LoginAgePrompt:OnActive()
  self.super.OnActive(self)
  local commonTextCfg = ConfirmCommonTipsIns:GetValue_ByID(9971)
  if not commonTextCfg:GetError() then
    self.m_textContentTemplate_Text.text = commonTextCfg.m_mcontent or ""
  end
end

function Form_LoginAgePrompt:OnInactive()
  self.super.OnInactive(self)
end

function Form_LoginAgePrompt:OnDestroy()
  self.super.OnDestroy(self)
end

function Form_LoginAgePrompt:OnBtnReturnClicked()
  self:CloseForm()
end

function Form_LoginAgePrompt:IsOpenGuassianBlur()
  return true
end

local fullscreen = true
ActiveLuaUI("Form_LoginAgePrompt", Form_LoginAgePrompt)
return Form_LoginAgePrompt
