local Form_CirculationUpgradeTipsUI = class("Form_CirculationUpgradeTipsUI", require("UI/Common/UIBase"))

function Form_CirculationUpgradeTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CirculationUpgradeTipsUI:GetID()
  return UIDefines.ID_FORM_CIRCULATIONUPGRADETIPS
end

function Form_CirculationUpgradeTipsUI:GetFramePrefabName()
  return "Form_CirculationUpgradeTips"
end

return Form_CirculationUpgradeTipsUI
