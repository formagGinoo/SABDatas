local Form_LegacyChangeUserUI = class("Form_LegacyChangeUserUI", require("UI/Common/UIBase"))

function Form_LegacyChangeUserUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyChangeUserUI:GetID()
  return UIDefines.ID_FORM_LEGACYCHANGEUSER
end

function Form_LegacyChangeUserUI:GetFramePrefabName()
  return "Form_LegacyChangeUser"
end

return Form_LegacyChangeUserUI
