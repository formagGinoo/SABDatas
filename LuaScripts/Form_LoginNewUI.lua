local Form_LoginNewUI = class("Form_LoginNewUI", require("UI/Common/UIBase"))

function Form_LoginNewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoginNewUI:GetID()
  return UIDefines.ID_FORM_LOGINNEW
end

function Form_LoginNewUI:GetFramePrefabName()
  return "Form_LoginNew"
end

return Form_LoginNewUI
