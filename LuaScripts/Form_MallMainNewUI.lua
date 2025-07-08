local Form_MallMainNewUI = class("Form_MallMainNewUI", require("UI/Common/UIBase"))

function Form_MallMainNewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MallMainNewUI:GetID()
  return UIDefines.ID_FORM_MALLMAINNEW
end

function Form_MallMainNewUI:GetFramePrefabName()
  return "Form_MallMainNew"
end

return Form_MallMainNewUI
