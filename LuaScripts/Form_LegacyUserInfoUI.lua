local Form_LegacyUserInfoUI = class("Form_LegacyUserInfoUI", require("UI/Common/UIBase"))

function Form_LegacyUserInfoUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyUserInfoUI:GetID()
  return UIDefines.ID_FORM_LEGACYUSERINFO
end

function Form_LegacyUserInfoUI:GetFramePrefabName()
  return "Form_LegacyUserInfo"
end

return Form_LegacyUserInfoUI
