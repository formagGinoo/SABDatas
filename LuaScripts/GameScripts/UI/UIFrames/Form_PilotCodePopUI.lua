local Form_PilotCodePopUI = class("Form_PilotCodePopUI", require("UI/Common/UIBase"))

function Form_PilotCodePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PilotCodePopUI:GetID()
  return UIDefines.ID_FORM_PILOTCODEPOP
end

function Form_PilotCodePopUI:GetFramePrefabName()
  return "Form_PilotCodePop"
end

return Form_PilotCodePopUI
