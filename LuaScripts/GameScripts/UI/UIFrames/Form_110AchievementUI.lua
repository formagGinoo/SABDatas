local Form_110AchievementUI = class("Form_110AchievementUI", require("UI/Common/HeroActBase/UIHeroActTaskBase"))

function Form_110AchievementUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_110AchievementUI:GetID()
  return UIDefines.ID_FORM_110ACHIEVEMENT
end

function Form_110AchievementUI:GetFramePrefabName()
  return "Form_110Achievement"
end

return Form_110AchievementUI
