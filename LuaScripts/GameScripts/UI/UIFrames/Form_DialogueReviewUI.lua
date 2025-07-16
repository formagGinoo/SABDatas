local Form_DialogueReviewUI = class("Form_DialogueReviewUI", require("UI/Common/UIBase"))

function Form_DialogueReviewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_DialogueReviewUI:GetID()
  return UIDefines.ID_FORM_DIALOGUEREVIEW
end

function Form_DialogueReviewUI:GetFramePrefabName()
  return "Form_DialogueReview"
end

return Form_DialogueReviewUI
