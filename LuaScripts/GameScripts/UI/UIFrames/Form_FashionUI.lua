local Form_FashionUI = class("Form_FashionUI", require("UI/Common/UIBase"))

function Form_FashionUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_FashionUI:GetID()
  return UIDefines.ID_FORM_FASHION
end

function Form_FashionUI:GetFramePrefabName()
  return "Form_Fashion"
end

return Form_FashionUI
