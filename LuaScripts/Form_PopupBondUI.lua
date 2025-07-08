local Form_PopupBondUI = class("Form_PopupBondUI", require("UI/Common/UIBase"))

function Form_PopupBondUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopupBondUI:GetID()
  return UIDefines.ID_FORM_POPUPBOND
end

function Form_PopupBondUI:GetFramePrefabName()
  return "Form_PopupBond"
end

return Form_PopupBondUI
