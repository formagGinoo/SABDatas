local Form_GachaWishPopUI = class("Form_GachaWishPopUI", require("UI/Common/UIBase"))

function Form_GachaWishPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GachaWishPopUI:GetID()
  return UIDefines.ID_FORM_GACHAWISHPOP
end

function Form_GachaWishPopUI:GetFramePrefabName()
  return "Form_GachaWishPop"
end

return Form_GachaWishPopUI
