local Form_EuipCrossTaskUI = class("Form_EuipCrossTaskUI", require("UI/Common/UIBase"))

function Form_EuipCrossTaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EuipCrossTaskUI:GetID()
  return UIDefines.ID_FORM_EUIPCROSSTASK
end

function Form_EuipCrossTaskUI:GetFramePrefabName()
  return "Form_EuipCrossTask"
end

return Form_EuipCrossTaskUI
