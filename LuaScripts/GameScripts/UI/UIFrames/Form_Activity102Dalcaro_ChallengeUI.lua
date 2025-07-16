local Form_Activity102Dalcaro_ChallengeUI = class("Form_Activity102Dalcaro_ChallengeUI", require("UI/Common/HeroActBase/UIHeroActChallengeBase"))

function Form_Activity102Dalcaro_ChallengeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_ChallengeUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_CHALLENGE
end

function Form_Activity102Dalcaro_ChallengeUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_Challenge"
end

return Form_Activity102Dalcaro_ChallengeUI
