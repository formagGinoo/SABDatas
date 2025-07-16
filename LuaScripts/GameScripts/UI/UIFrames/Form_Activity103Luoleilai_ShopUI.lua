local Form_Activity103Luoleilai_ShopUI = class("Form_Activity103Luoleilai_ShopUI", require("UI/Common/HeroActBase/UIHeroActShopBase"))

function Form_Activity103Luoleilai_ShopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity103Luoleilai_ShopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_SHOP
end

function Form_Activity103Luoleilai_ShopUI:GetFramePrefabName()
  return "Form_Activity103Luoleilai_Shop"
end

return Form_Activity103Luoleilai_ShopUI
