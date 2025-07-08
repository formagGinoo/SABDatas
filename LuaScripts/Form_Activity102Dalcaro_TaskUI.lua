local Form_Activity102Dalcaro_TaskUI = class("Form_Activity102Dalcaro_TaskUI", require("UI/Common/HeroActBase/UIHeroActTaskBase"))

function Form_Activity102Dalcaro_TaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_TaskUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_TASK
end

function Form_Activity102Dalcaro_TaskUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_Task"
end

return Form_Activity102Dalcaro_TaskUI
