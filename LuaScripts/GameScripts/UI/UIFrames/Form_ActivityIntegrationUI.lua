local Form_ActivityIntegrationUI = class("Form_ActivityIntegrationUI", require("UI/Common/UIBase"))

function Form_ActivityIntegrationUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityIntegrationUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYINTEGRATION
end

function Form_ActivityIntegrationUI:GetFramePrefabName()
  return "Form_ActivityIntegration"
end

return Form_ActivityIntegrationUI
