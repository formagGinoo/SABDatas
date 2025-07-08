local Form_TaskUI = class("Form_TaskUI", require("UI/Common/UIBase"))

function Form_TaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_TaskUI:GetID()
  return UIDefines.ID_FORM_TASK
end

function Form_TaskUI:GetFramePrefabName()
  return "Form_Task"
end

return Form_TaskUI
