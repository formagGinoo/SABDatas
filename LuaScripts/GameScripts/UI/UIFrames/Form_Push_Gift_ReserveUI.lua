local Form_Push_Gift_ReserveUI = class("Form_Push_Gift_ReserveUI", require("UI/Common/UIBase"))

function Form_Push_Gift_ReserveUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Push_Gift_ReserveUI:GetID()
  return UIDefines.ID_FORM_PUSH_GIFT_RESERVE
end

function Form_Push_Gift_ReserveUI:GetFramePrefabName()
  return "Form_Push_Gift_Reserve"
end

return Form_Push_Gift_ReserveUI
