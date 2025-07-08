local Form_Activity101Lamia_ChallengeUI = class("Form_Activity101Lamia_ChallengeUI", require("UI/Common/HeroActBase/UIHeroActChallengeBase"))

function Form_Activity101Lamia_ChallengeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ChallengeUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_CHALLENGE
end

function Form_Activity101Lamia_ChallengeUI:GetFramePrefabName()
  return "Form_Activity101Lamia_Challenge"
end

return Form_Activity101Lamia_ChallengeUI
