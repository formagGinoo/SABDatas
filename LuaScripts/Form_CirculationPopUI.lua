local Form_CirculationPopUI = class("Form_CirculationPopUI", require("UI/Common/UIBase"))

function Form_CirculationPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CirculationPopUI:GetID()
  return UIDefines.ID_FORM_CIRCULATIONPOP
end

function Form_CirculationPopUI:GetFramePrefabName()
  return "Form_CirculationPop"
end

return Form_CirculationPopUI
