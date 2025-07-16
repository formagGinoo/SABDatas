local Form_activity104_DialogueclueUI = class("Form_activity104_DialogueclueUI", require("UI/Common/UIBase"))

function Form_activity104_DialogueclueUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_activity104_DialogueclueUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY104_DIALOGUECLUE
end

function Form_activity104_DialogueclueUI:GetFramePrefabName()
  return "Form_activity104_Dialogueclue"
end

return Form_activity104_DialogueclueUI
