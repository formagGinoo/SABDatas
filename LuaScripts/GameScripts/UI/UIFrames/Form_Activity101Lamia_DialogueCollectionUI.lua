local Form_Activity101Lamia_DialogueCollectionUI = class("Form_Activity101Lamia_DialogueCollectionUI", require("UI/Common/HeroActBase/UIHeroActDialogueCollectionBase"))

function Form_Activity101Lamia_DialogueCollectionUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_DialogueCollectionUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_DIALOGUECOLLECTION
end

function Form_Activity101Lamia_DialogueCollectionUI:GetFramePrefabName()
  return "Form_Activity101Lamia_DialogueCollection"
end

return Form_Activity101Lamia_DialogueCollectionUI
