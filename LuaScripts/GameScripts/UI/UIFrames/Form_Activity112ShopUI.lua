local Form_Activity112ShopUI = class("Form_Activity112ShopUI", require("UI/Common/HeroActBase/UIHeroActShopBase"))

function Form_Activity112ShopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity112ShopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY112SHOP
end

function Form_Activity112ShopUI:GetFramePrefabName()
  return "Form_Activity112Shop"
end

return Form_Activity112ShopUI
