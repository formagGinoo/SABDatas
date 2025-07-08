local Form_ActivityDailyLoginUI = class("Form_ActivityDailyLoginUI", require("UI/Common/UIBase"))

function Form_ActivityDailyLoginUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityDailyLoginUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYDAILYLOGIN
end

function Form_ActivityDailyLoginUI:GetFramePrefabName()
  return "Form_ActivityDailyLogin"
end

return Form_ActivityDailyLoginUI
