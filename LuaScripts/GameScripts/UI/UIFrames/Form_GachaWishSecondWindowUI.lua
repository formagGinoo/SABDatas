local Form_GachaWishSecondWindowUI = class("Form_GachaWishSecondWindowUI", require("UI/Common/UIBase"))

function Form_GachaWishSecondWindowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GachaWishSecondWindowUI:GetID()
  return UIDefines.ID_FORM_GACHAWISHSECONDWINDOW
end

function Form_GachaWishSecondWindowUI:GetFramePrefabName()
  return "Form_GachaWishSecondWindow"
end

return Form_GachaWishSecondWindowUI
