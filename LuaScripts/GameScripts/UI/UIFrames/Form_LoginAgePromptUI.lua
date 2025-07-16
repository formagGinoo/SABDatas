local Form_LoginAgePromptUI = class("Form_LoginAgePromptUI", require("UI/Common/UIBase"))

function Form_LoginAgePromptUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoginAgePromptUI:GetID()
  return UIDefines.ID_FORM_LOGINAGEPROMPT
end

function Form_LoginAgePromptUI:GetFramePrefabName()
  return "Form_LoginAgePrompt"
end

return Form_LoginAgePromptUI
