local Form_ShopUI = class("Form_ShopUI", require("UI/Common/UIBase"))

function Form_ShopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ShopUI:GetID()
  return UIDefines.ID_FORM_SHOP
end

function Form_ShopUI:GetFramePrefabName()
  return "Form_Shop"
end

return Form_ShopUI
