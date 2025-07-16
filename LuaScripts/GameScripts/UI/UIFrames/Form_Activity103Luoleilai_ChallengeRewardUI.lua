local Form_Activity103Luoleilai_ChallengeRewardUI = class("Form_Activity103Luoleilai_ChallengeRewardUI", require("UI/Common/HeroActBase/UIHeroActChallengeRewardBase"))

function Form_Activity103Luoleilai_ChallengeRewardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity103Luoleilai_ChallengeRewardUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_CHALLENGEREWARD
end

function Form_Activity103Luoleilai_ChallengeRewardUI:GetFramePrefabName()
  return "Form_Activity103Luoleilai_ChallengeReward"
end

return Form_Activity103Luoleilai_ChallengeRewardUI
