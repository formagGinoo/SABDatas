local Form_Activity112_DialogueMainUI = class("Form_Activity112_DialogueMainUI", require("UI/Common/HeroActBase/UIHeroActDialogueMainBase"))

function Form_Activity112_DialogueMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity112_DialogueMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY112_DIALOGUEMAIN
end

function Form_Activity112_DialogueMainUI:GetFramePrefabName()
  return "Form_Activity112_DialogueMain"
end

return Form_Activity112_DialogueMainUI
