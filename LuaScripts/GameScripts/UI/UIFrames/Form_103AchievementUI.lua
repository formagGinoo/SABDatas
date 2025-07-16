local Form_103AchievementUI = class("Form_103AchievementUI", require("UI/Common/UIBase"))

function Form_103AchievementUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_103AchievementUI:GetID()
  return UIDefines.ID_FORM_103ACHIEVEMENT
end

function Form_103AchievementUI:GetFramePrefabName()
  return "Form_103Achievement"
end

return Form_103AchievementUI
