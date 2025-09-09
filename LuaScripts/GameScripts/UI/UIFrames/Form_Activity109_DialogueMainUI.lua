local Form_Activity109_DialogueMainUI = class("Form_Activity109_DialogueMainUI", require("UI/Common/HeroActBase/UIHeroActDialogueMainBase"))

function Form_Activity109_DialogueMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity109_DialogueMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY109_DIALOGUEMAIN
end

function Form_Activity109_DialogueMainUI:GetFramePrefabName()
  return "Form_Activity109_DialogueMain"
end

return Form_Activity109_DialogueMainUI
