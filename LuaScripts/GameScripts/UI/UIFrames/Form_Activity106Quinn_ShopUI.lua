local Form_Activity106Quinn_ShopUI = class("Form_Activity106Quinn_ShopUI", require("UI/Common/HeroActBase/UIHeroActShopBase"))

function Form_Activity106Quinn_ShopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity106Quinn_ShopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY106QUINN_SHOP
end

function Form_Activity106Quinn_ShopUI:GetFramePrefabName()
  return "Form_Activity106Quinn_Shop"
end

return Form_Activity106Quinn_ShopUI
