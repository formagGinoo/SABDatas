local Form_EmailUI = class("Form_EmailUI", require("UI/Common/UIBase"))

function Form_EmailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EmailUI:GetID()
  return UIDefines.ID_FORM_EMAIL
end

function Form_EmailUI:GetFramePrefabName()
  return "Form_Email"
end

return Form_EmailUI
