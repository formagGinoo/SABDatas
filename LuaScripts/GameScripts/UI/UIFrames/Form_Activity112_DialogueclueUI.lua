local Form_Activity112_DialogueclueUI = class("Form_Activity112_DialogueclueUI", require("UI/Common/HeroActBase/DialogueclueBase"))

function Form_Activity112_DialogueclueUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity112_DialogueclueUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY112_DIALOGUECLUE
end

function Form_Activity112_DialogueclueUI:GetFramePrefabName()
  return "Form_Activity112_Dialogueclue"
end

return Form_Activity112_DialogueclueUI
