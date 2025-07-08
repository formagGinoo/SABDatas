local Form_ActivityDayTaskUI = class("Form_ActivityDayTaskUI", require("UI/Common/UIBase"))

function Form_ActivityDayTaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityDayTaskUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYDAYTASK
end

function Form_ActivityDayTaskUI:GetFramePrefabName()
  return "Form_ActivityDayTask"
end

return Form_ActivityDayTaskUI
