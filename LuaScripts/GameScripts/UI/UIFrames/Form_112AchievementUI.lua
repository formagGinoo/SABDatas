local Form_112AchievementUI = class("Form_112AchievementUI", require("UI/Common/HeroActBase/UIHeroActTaskBase"))

function Form_112AchievementUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_112AchievementUI:GetID()
  return UIDefines.ID_FORM_112ACHIEVEMENT
end

function Form_112AchievementUI:GetFramePrefabName()
  return "Form_112Achievement"
end

return Form_112AchievementUI
