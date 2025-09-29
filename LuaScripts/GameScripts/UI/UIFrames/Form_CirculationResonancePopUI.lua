local Form_CirculationResonancePopUI = class("Form_CirculationResonancePopUI", require("UI/Common/UIBase"))

function Form_CirculationResonancePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CirculationResonancePopUI:GetID()
  return UIDefines.ID_FORM_CIRCULATIONRESONANCEPOP
end

function Form_CirculationResonancePopUI:GetFramePrefabName()
  return "Form_CirculationResonancePop"
end

return Form_CirculationResonancePopUI
