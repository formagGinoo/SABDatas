local Form_ActivityQuestionUI = class("Form_ActivityQuestionUI", require("UI/Common/UIBase"))

function Form_ActivityQuestionUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityQuestionUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYQUESTION
end

function Form_ActivityQuestionUI:GetFramePrefabName()
  return "Form_ActivityQuestion"
end

return Form_ActivityQuestionUI
