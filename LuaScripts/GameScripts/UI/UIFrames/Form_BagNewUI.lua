local Form_BagNewUI = class("Form_BagNewUI", require("UI/Common/UIBase"))

function Form_BagNewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BagNewUI:GetID()
  return UIDefines.ID_FORM_BAGNEW
end

function Form_BagNewUI:GetFramePrefabName()
  return "Form_BagNew"
end

return Form_BagNewUI
