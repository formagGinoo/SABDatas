local Form_Activity101Lamia_DialogueMainUI = class("Form_Activity101Lamia_DialogueMainUI", require("UI/Common/HeroActBase/UIHeroActDialogueMainBase"))

function Form_Activity101Lamia_DialogueMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_DialogueMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_DIALOGUEMAIN
end

function Form_Activity101Lamia_DialogueMainUI:GetFramePrefabName()
  return "Form_Activity101Lamia_DialogueMain"
end

return Form_Activity101Lamia_DialogueMainUI
