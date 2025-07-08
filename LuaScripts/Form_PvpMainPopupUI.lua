local Form_PvpMainPopupUI = class("Form_PvpMainPopupUI", require("UI/Common/UIBase"))

function Form_PvpMainPopupUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpMainPopupUI:GetID()
  return UIDefines.ID_FORM_PVPMAINPOPUP
end

function Form_PvpMainPopupUI:GetFramePrefabName()
  return "Form_PvpMainPopup"
end

return Form_PvpMainPopupUI
