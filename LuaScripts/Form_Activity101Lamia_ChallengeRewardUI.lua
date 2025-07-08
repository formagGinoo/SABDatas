local Form_Activity101Lamia_ChallengeRewardUI = class("Form_Activity101Lamia_ChallengeRewardUI", require("UI/Common/HeroActBase/UIHeroActChallengeRewardBase"))

function Form_Activity101Lamia_ChallengeRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_ChallengeRewardUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_CHALLENGEREWARD
end

function Form_Activity101Lamia_ChallengeRewardUI:GetFramePrefabName()
  return "Form_Activity101Lamia_ChallengeReward"
end

return Form_Activity101Lamia_ChallengeRewardUI
