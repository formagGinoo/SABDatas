local Form_Activity102Dalcaro_ShopUI = class("Form_Activity102Dalcaro_ShopUI", require("UI/Common/HeroActBase/UIHeroActShopBase"))

function Form_Activity102Dalcaro_ShopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_ShopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_SHOP
end

function Form_Activity102Dalcaro_ShopUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_Shop"
end

return Form_Activity102Dalcaro_ShopUI
