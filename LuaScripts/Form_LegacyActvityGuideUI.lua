local Form_LegacyActvityGuideUI = class("Form_LegacyActvityGuideUI", require("UI/Common/UIBase"))

function Form_LegacyActvityGuideUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyActvityGuideUI:GetID()
  return UIDefines.ID_FORM_LEGACYACTVITYGUIDE
end

function Form_LegacyActvityGuideUI:GetFramePrefabName()
  return "Form_LegacyActvityGuide"
end

return Form_LegacyActvityGuideUI
