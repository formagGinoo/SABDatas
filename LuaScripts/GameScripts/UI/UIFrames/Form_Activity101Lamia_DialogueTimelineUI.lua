local Form_Activity101Lamia_DialogueTimelineUI = class("Form_Activity101Lamia_DialogueTimelineUI", require("UI/Common/UIBase"))

function Form_Activity101Lamia_DialogueTimelineUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_DialogueTimelineUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_DIALOGUETIMELINE
end

function Form_Activity101Lamia_DialogueTimelineUI:GetFramePrefabName()
  return "Form_Activity101Lamia_DialogueTimeline"
end

return Form_Activity101Lamia_DialogueTimelineUI
