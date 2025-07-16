local Form_LegacyLockTipsUI = class("Form_LegacyLockTipsUI", require("UI/Common/UIBase"))

function Form_LegacyLockTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyLockTipsUI:GetID()
  return UIDefines.ID_FORM_LEGACYLOCKTIPS
end

function Form_LegacyLockTipsUI:GetFramePrefabName()
  return "Form_LegacyLockTips"
end

return Form_LegacyLockTipsUI
