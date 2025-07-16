local Form_Activity103Luoleilai_ChallengeHeroUI = class("Form_Activity103Luoleilai_ChallengeHeroUI", require("UI/Common/HeroActBase/UIHeroActChallengeHeroBase"))

function Form_Activity103Luoleilai_ChallengeHeroUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity103Luoleilai_ChallengeHeroUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_CHALLENGEHERO
end

function Form_Activity103Luoleilai_ChallengeHeroUI:GetFramePrefabName()
  return "Form_Activity103Luoleilai_ChallengeHero"
end

return Form_Activity103Luoleilai_ChallengeHeroUI
