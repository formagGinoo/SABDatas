local Form_AVGDialogueUI = class("Form_AVGDialogueUI", require("UI/Common/UIBase"))

function Form_AVGDialogueUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AVGDialogueUI:GetID()
  return UIDefines.ID_FORM_AVGDIALOGUE
end

function Form_AVGDialogueUI:GetFramePrefabName()
  return "Form_AVGDialogue"
end

return Form_AVGDialogueUI
