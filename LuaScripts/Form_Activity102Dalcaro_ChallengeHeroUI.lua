local Form_Activity102Dalcaro_ChallengeHeroUI = class("Form_Activity102Dalcaro_ChallengeHeroUI", require("UI/Common/HeroActBase/UIHeroActChallengeHeroBase"))

function Form_Activity102Dalcaro_ChallengeHeroUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_ChallengeHeroUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_CHALLENGEHERO
end

function Form_Activity102Dalcaro_ChallengeHeroUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_ChallengeHero"
end

return Form_Activity102Dalcaro_ChallengeHeroUI
