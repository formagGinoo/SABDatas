local Form_Activity103Luoleilai_ChallengeUI = class("Form_Activity103Luoleilai_ChallengeUI", require("UI/Common/UIBase"))

function Form_Activity103Luoleilai_ChallengeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity103Luoleilai_ChallengeUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_CHALLENGE
end

function Form_Activity103Luoleilai_ChallengeUI:GetFramePrefabName()
  return "Form_Activity103Luoleilai_Challenge"
end

return Form_Activity103Luoleilai_ChallengeUI
