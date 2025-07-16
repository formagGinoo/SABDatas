local Form_CirculationMainUI = class("Form_CirculationMainUI", require("UI/Common/UIBase"))

function Form_CirculationMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_CirculationMainUI:GetID()
  return UIDefines.ID_FORM_CIRCULATIONMAIN
end

function Form_CirculationMainUI:GetFramePrefabName()
  return "Form_CirculationMain"
end

return Form_CirculationMainUI
