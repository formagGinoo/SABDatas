local Form_DialogueUI = class("Form_DialogueUI", require("UI/Common/UIBase"))

function Form_DialogueUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_DialogueUI:GetID()
  return UIDefines.ID_FORM_DIALOGUE
end

function Form_DialogueUI:GetFramePrefabName()
  return "Form_Dialogue"
end

return Form_DialogueUI
