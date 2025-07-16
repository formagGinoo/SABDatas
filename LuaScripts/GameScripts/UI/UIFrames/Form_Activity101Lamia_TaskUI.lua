local Form_Activity101Lamia_TaskUI = class("Form_Activity101Lamia_TaskUI", require("UI/Common/HeroActBase/UIHeroActTaskBase"))

function Form_Activity101Lamia_TaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_TaskUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_TASK
end

function Form_Activity101Lamia_TaskUI:GetFramePrefabName()
  return "Form_Activity101Lamia_Task"
end

return Form_Activity101Lamia_TaskUI
