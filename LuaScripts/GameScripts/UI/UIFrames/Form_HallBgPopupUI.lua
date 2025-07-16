local Form_HallBgPopupUI = class("Form_HallBgPopupUI", require("UI/Common/UIBase"))

function Form_HallBgPopupUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HallBgPopupUI:GetID()
  return UIDefines.ID_FORM_HALLBGPOPUP
end

function Form_HallBgPopupUI:GetFramePrefabName()
  return "Form_HallBgPopup"
end

return Form_HallBgPopupUI
