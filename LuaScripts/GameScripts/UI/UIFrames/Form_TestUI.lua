local Form_TestUI = class("Form_TestUI", require("UI/Common/UIBase"))

function Form_TestUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_TestUI:GetID()
  return UIDefines.ID_FORM_TEST
end

function Form_TestUI:GetFramePrefabName()
  return "Form_Test"
end

return Form_TestUI
