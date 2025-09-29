local Form_ActivityEventCalendarPopUI = class("Form_ActivityEventCalendarPopUI", require("UI/Common/UIBase"))

function Form_ActivityEventCalendarPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityEventCalendarPopUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYEVENTCALENDARPOP
end

function Form_ActivityEventCalendarPopUI:GetFramePrefabName()
  return "Form_ActivityEventCalendarPop"
end

return Form_ActivityEventCalendarPopUI
