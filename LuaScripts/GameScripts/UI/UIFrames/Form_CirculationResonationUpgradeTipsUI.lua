local Form_CirculationResonationUpgradeTipsUI = class("Form_CirculationResonationUpgradeTipsUI", require("UI/Common/UIBase"))

function Form_CirculationResonationUpgradeTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CirculationResonationUpgradeTipsUI:GetID()
  return UIDefines.ID_FORM_CIRCULATIONRESONATIONUPGRADETIPS
end

function Form_CirculationResonationUpgradeTipsUI:GetFramePrefabName()
  return "Form_CirculationResonationUpgradeTips"
end

return Form_CirculationResonationUpgradeTipsUI
