local Form_Lounge_TestUI = class("Form_Lounge_TestUI", require("UI/Common/UIBase"))

function Form_Lounge_TestUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Lounge_TestUI:GetID()
  return UIDefines.ID_FORM_LOUNGE_TEST
end

function Form_Lounge_TestUI:GetFramePrefabName()
  return "Form_Lounge_Test"
end

return Form_Lounge_TestUI
