local Form_PilotCodeTipsPopUI = class("Form_PilotCodeTipsPopUI", require("UI/Common/UIBase"))

function Form_PilotCodeTipsPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PilotCodeTipsPopUI:GetID()
  return UIDefines.ID_FORM_PILOTCODETIPSPOP
end

function Form_PilotCodeTipsPopUI:GetFramePrefabName()
  return "Form_PilotCodeTipsPop"
end

return Form_PilotCodeTipsPopUI
