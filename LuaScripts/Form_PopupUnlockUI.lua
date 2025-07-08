local Form_PopupUnlockUI = class("Form_PopupUnlockUI", require("UI/Common/UIBase"))

function Form_PopupUnlockUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopupUnlockUI:GetID()
  return UIDefines.ID_FORM_POPUPUNLOCK
end

function Form_PopupUnlockUI:GetFramePrefabName()
  return "Form_PopupUnlock"
end

return Form_PopupUnlockUI
