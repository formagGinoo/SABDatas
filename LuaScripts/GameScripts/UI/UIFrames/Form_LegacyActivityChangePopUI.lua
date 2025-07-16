local Form_LegacyActivityChangePopUI = class("Form_LegacyActivityChangePopUI", require("UI/Common/UIBase"))

function Form_LegacyActivityChangePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyActivityChangePopUI:GetID()
  return UIDefines.ID_FORM_LEGACYACTIVITYCHANGEPOP
end

function Form_LegacyActivityChangePopUI:GetFramePrefabName()
  return "Form_LegacyActivityChangePop"
end

return Form_LegacyActivityChangePopUI
