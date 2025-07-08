local Form_HeroSkillLevelUp_TipsUI = class("Form_HeroSkillLevelUp_TipsUI", require("UI/Common/UIBase"))

function Form_HeroSkillLevelUp_TipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroSkillLevelUp_TipsUI:GetID()
  return UIDefines.ID_FORM_HEROSKILLLEVELUP_TIPS
end

function Form_HeroSkillLevelUp_TipsUI:GetFramePrefabName()
  return "Form_HeroSkillLevelUp_Tips"
end

return Form_HeroSkillLevelUp_TipsUI
