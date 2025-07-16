local Form_Activity103Luoleilai_DialogueMainUI = class("Form_Activity103Luoleilai_DialogueMainUI", require("UI/Common/HeroActBase/UIHeroActDialogueMainBase"))

function Form_Activity103Luoleilai_DialogueMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity103Luoleilai_DialogueMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_DIALOGUEMAIN
end

function Form_Activity103Luoleilai_DialogueMainUI:GetFramePrefabName()
  return "Form_Activity103Luoleilai_DialogueMain"
end

return Form_Activity103Luoleilai_DialogueMainUI
