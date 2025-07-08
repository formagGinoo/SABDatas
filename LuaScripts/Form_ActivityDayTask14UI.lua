local Form_ActivityDayTask14UI = class("Form_ActivityDayTask14UI", require("UI/Common/UIBase"))

function Form_ActivityDayTask14UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityDayTask14UI:GetID()
  return UIDefines.ID_FORM_ACTIVITYDAYTASK14
end

function Form_ActivityDayTask14UI:GetFramePrefabName()
  return "Form_ActivityDayTask14"
end

return Form_ActivityDayTask14UI
