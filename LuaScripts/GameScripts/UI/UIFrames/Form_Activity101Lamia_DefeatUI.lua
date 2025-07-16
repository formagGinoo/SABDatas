local Form_Activity101Lamia_DefeatUI = class("Form_Activity101Lamia_DefeatUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_DefeatUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_DefeatUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_DEFEAT
end

function Form_Activity101Lamia_DefeatUI:GetFramePrefabName()
  return "Form_Activity101Lamia_Defeat"
end

return Form_Activity101Lamia_DefeatUI
