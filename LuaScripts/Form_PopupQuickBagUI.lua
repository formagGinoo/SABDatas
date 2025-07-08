local Form_PopupQuickBagUI = class("Form_PopupQuickBagUI", require("UI/Common/UIBase"))

function Form_PopupQuickBagUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopupQuickBagUI:GetID()
  return UIDefines.ID_FORM_POPUPQUICKBAG
end

function Form_PopupQuickBagUI:GetFramePrefabName()
  return "Form_PopupQuickBag"
end

return Form_PopupQuickBagUI
