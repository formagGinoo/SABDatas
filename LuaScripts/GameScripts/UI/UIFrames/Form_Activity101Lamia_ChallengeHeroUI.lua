local Form_Activity101Lamia_ChallengeHeroUI = class("Form_Activity101Lamia_ChallengeHeroUI", require("UI/Common/HeroActBase/UIHeroActChallengeHeroBase"))

function Form_Activity101Lamia_ChallengeHeroUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ChallengeHeroUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_CHALLENGEHERO
end

function Form_Activity101Lamia_ChallengeHeroUI:GetFramePrefabName()
  return "Form_Activity101Lamia_ChallengeHero"
end

return Form_Activity101Lamia_ChallengeHeroUI
