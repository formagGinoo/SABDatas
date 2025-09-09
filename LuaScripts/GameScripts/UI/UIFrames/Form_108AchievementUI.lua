local Form_108AchievementUI = class("Form_108AchievementUI", require("UI/Common/HeroActBase/UIHeroActAchievementBase"))

function Form_108AchievementUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_108AchievementUI:GetID()
  return UIDefines.ID_FORM_108ACHIEVEMENT
end

function Form_108AchievementUI:GetFramePrefabName()
  return "Form_108Achievement"
end

return Form_108AchievementUI
