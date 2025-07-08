local Form_LoginUI = class("Form_LoginUI", require("UI/Common/UIBase"))

function Form_LoginUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoginUI:GetID()
  return UIDefines.ID_FORM_LOGIN
end

function Form_LoginUI:GetFramePrefabName()
  return "Form_Login"
end

return Form_LoginUI
