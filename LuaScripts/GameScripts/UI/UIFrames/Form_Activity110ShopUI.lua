local Form_Activity110ShopUI = class("Form_Activity110ShopUI", require("UI/Common/HeroActBase/UIHeroActShopBase"))

function Form_Activity110ShopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110ShopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110SHOP
end

function Form_Activity110ShopUI:GetFramePrefabName()
  return "Form_Activity110Shop"
end

return Form_Activity110ShopUI
