local Form_CirculationLevelUpUI = class("Form_CirculationLevelUpUI", require("UI/Common/UIBase"))

function Form_CirculationLevelUpUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CirculationLevelUpUI:GetID()
  return UIDefines.ID_FORM_CIRCULATIONLEVELUP
end

function Form_CirculationLevelUpUI:GetFramePrefabName()
  return "Form_CirculationLevelUp"
end

return Form_CirculationLevelUpUI
