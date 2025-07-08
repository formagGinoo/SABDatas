local Form_LegacyActivityMainUI = class("Form_LegacyActivityMainUI", require("UI/Common/UIBase"))

function Form_LegacyActivityMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyActivityMainUI:GetID()
  return UIDefines.ID_FORM_LEGACYACTIVITYMAIN
end

function Form_LegacyActivityMainUI:GetFramePrefabName()
  return "Form_LegacyActivityMain"
end

return Form_LegacyActivityMainUI
