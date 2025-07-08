local Form_Dialogue_PopoUI = class("Form_Dialogue_PopoUI", require("UI/Common/UIBase"))

function Form_Dialogue_PopoUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Dialogue_PopoUI:GetID()
  return UIDefines.ID_FORM_DIALOGUE_POPO
end

function Form_Dialogue_PopoUI:GetFramePrefabName()
  return "Form_Dialogue_Popo"
end

return Form_Dialogue_PopoUI
