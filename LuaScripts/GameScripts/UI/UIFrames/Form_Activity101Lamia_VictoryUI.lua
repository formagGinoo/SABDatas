local Form_Activity101Lamia_VictoryUI = class("Form_Activity101Lamia_VictoryUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_VictoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_VictoryUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_VICTORY
end

function Form_Activity101Lamia_VictoryUI:GetFramePrefabName()
  return "Form_Activity101Lamia_Victory"
end

return Form_Activity101Lamia_VictoryUI
