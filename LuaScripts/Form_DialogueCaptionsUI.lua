local Form_DialogueCaptionsUI = class("Form_DialogueCaptionsUI", require("UI/Common/UIBase"))

function Form_DialogueCaptionsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_DialogueCaptionsUI:GetID()
  return UIDefines.ID_FORM_DIALOGUECAPTIONS
end

function Form_DialogueCaptionsUI:GetFramePrefabName()
  return "Form_DialogueCaptions"
end

return Form_DialogueCaptionsUI
