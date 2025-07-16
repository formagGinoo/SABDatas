local Form_LegacyActivityWinUI = class("Form_LegacyActivityWinUI", require("UI/Common/UIBase"))

function Form_LegacyActivityWinUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyActivityWinUI:GetID()
  return UIDefines.ID_FORM_LEGACYACTIVITYWIN
end

function Form_LegacyActivityWinUI:GetFramePrefabName()
  return "Form_LegacyActivityWin"
end

return Form_LegacyActivityWinUI
