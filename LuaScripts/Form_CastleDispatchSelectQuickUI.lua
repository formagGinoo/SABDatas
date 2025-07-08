local Form_CastleDispatchSelectQuickUI = class("Form_CastleDispatchSelectQuickUI", require("UI/Common/UIBase"))

function Form_CastleDispatchSelectQuickUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CastleDispatchSelectQuickUI:GetID()
  return UIDefines.ID_FORM_CASTLEDISPATCHSELECTQUICK
end

function Form_CastleDispatchSelectQuickUI:GetFramePrefabName()
  return "Form_CastleDispatchSelectQuick"
end

return Form_CastleDispatchSelectQuickUI
