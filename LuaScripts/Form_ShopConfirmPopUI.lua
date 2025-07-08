local Form_ShopConfirmPopUI = class("Form_ShopConfirmPopUI", require("UI/Common/UIBase"))

function Form_ShopConfirmPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ShopConfirmPopUI:GetID()
  return UIDefines.ID_FORM_SHOPCONFIRMPOP
end

function Form_ShopConfirmPopUI:GetFramePrefabName()
  return "Form_ShopConfirmPop"
end

return Form_ShopConfirmPopUI
