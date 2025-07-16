local Form_Activity101Lamia_ShopUI = class("Form_Activity101Lamia_ShopUI", require("UI/Common/HeroActBase/UIHeroActShopBase"))

function Form_Activity101Lamia_ShopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ShopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_SHOP
end

function Form_Activity101Lamia_ShopUI:GetFramePrefabName()
  return "Form_Activity101Lamia_Shop"
end

return Form_Activity101Lamia_ShopUI
