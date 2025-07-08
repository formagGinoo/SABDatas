local Form_CastleDispatchPopupUI = class("Form_CastleDispatchPopupUI", require("UI/Common/UIBase"))

function Form_CastleDispatchPopupUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleDispatchPopupUI:GetID()
  return UIDefines.ID_FORM_CASTLEDISPATCHPOPUP
end

function Form_CastleDispatchPopupUI:GetFramePrefabName()
  return "Form_CastleDispatchPopup"
end

return Form_CastleDispatchPopupUI
