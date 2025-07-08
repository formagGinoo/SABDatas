local Form_AttractDialogueUI = class("Form_AttractDialogueUI", require("UI/Common/UIBase"))

function Form_AttractDialogueUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractDialogueUI:GetID()
  return UIDefines.ID_FORM_ATTRACTDIALOGUE
end

function Form_AttractDialogueUI:GetFramePrefabName()
  return "Form_AttractDialogue"
end

return Form_AttractDialogueUI
