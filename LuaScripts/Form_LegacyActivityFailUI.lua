local Form_LegacyActivityFailUI = class("Form_LegacyActivityFailUI", require("UI/Common/UIBase"))

function Form_LegacyActivityFailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyActivityFailUI:GetID()
  return UIDefines.ID_FORM_LEGACYACTIVITYFAIL
end

function Form_LegacyActivityFailUI:GetFramePrefabName()
  return "Form_LegacyActivityFail"
end

return Form_LegacyActivityFailUI
