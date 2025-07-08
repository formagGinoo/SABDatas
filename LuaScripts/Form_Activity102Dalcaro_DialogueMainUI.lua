local Form_Activity102Dalcaro_DialogueMainUI = class("Form_Activity102Dalcaro_DialogueMainUI", require("UI/Common/HeroActBase/UIHeroActDialogueMainBase"))

function Form_Activity102Dalcaro_DialogueMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_DialogueMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_DIALOGUEMAIN
end

function Form_Activity102Dalcaro_DialogueMainUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_DialogueMain"
end

return Form_Activity102Dalcaro_DialogueMainUI
