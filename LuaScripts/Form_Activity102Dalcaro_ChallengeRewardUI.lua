local Form_Activity102Dalcaro_ChallengeRewardUI = class("Form_Activity102Dalcaro_ChallengeRewardUI", require("UI/Common/HeroActBase/UIHeroActChallengeRewardBase"))

function Form_Activity102Dalcaro_ChallengeRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_ChallengeRewardUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_CHALLENGEREWARD
end

function Form_Activity102Dalcaro_ChallengeRewardUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_ChallengeReward"
end

return Form_Activity102Dalcaro_ChallengeRewardUI
