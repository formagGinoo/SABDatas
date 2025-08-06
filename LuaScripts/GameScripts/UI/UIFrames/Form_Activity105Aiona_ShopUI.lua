local Form_Activity105Aiona_ShopUI = class("Form_Activity105Aiona_ShopUI", require("UI/Common/HeroActBase/UIHeroActShopBase"))

function Form_Activity105Aiona_ShopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105Aiona_ShopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105AIONA_SHOP
end

function Form_Activity105Aiona_ShopUI:GetFramePrefabName()
  return "Form_Activity105Aiona_Shop"
end

return Form_Activity105Aiona_ShopUI
