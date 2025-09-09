local Form_Activity108ShopUI = class("Form_Activity108ShopUI", require("UI/Common/HeroActBase/UIHeroActShopBase"))

function Form_Activity108ShopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity108ShopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY108SHOP
end

function Form_Activity108ShopUI:GetFramePrefabName()
  return "Form_Activity108Shop"
end

return Form_Activity108ShopUI
