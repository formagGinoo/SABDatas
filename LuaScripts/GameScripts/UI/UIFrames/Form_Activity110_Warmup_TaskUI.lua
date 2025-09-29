local Form_Activity110_Warmup_TaskUI = class("Form_Activity110_Warmup_TaskUI", require("UI/Common/UIBase"))

function Form_Activity110_Warmup_TaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110_Warmup_TaskUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110_WARMUP_TASK
end

function Form_Activity110_Warmup_TaskUI:GetFramePrefabName()
  return "Form_Activity110_Warmup_Task"
end

return Form_Activity110_Warmup_TaskUI
