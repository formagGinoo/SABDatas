local Form_LegacyActivityCubePopUI = class("Form_LegacyActivityCubePopUI", require("UI/Common/UIBase"))

function Form_LegacyActivityCubePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LegacyActivityCubePopUI:GetID()
  return UIDefines.ID_FORM_LEGACYACTIVITYCUBEPOP
end

function Form_LegacyActivityCubePopUI:GetFramePrefabName()
  return "Form_LegacyActivityCubePop"
end

return Form_LegacyActivityCubePopUI
