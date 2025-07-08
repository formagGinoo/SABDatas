local Form_102DalcaroShopConfirmPopUI = class("Form_102DalcaroShopConfirmPopUI", require("UI/Common/UIBase"))

function Form_102DalcaroShopConfirmPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_102DalcaroShopConfirmPopUI:GetID()
  return UIDefines.ID_FORM_102DALCAROSHOPCONFIRMPOP
end

function Form_102DalcaroShopConfirmPopUI:GetFramePrefabName()
  return "Form_102DalcaroShopConfirmPop"
end

return Form_102DalcaroShopConfirmPopUI
