local Form_LegacyActivityGuideUI = class("Form_LegacyActivityGuideUI", require("UI/Common/UIBase"))

function Form_LegacyActivityGuideUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyActivityGuideUI:GetID()
  return UIDefines.ID_FORM_LEGACYACTIVITYGUIDE
end

function Form_LegacyActivityGuideUI:GetFramePrefabName()
  return "Form_LegacyActivityGuide"
end

return Form_LegacyActivityGuideUI
