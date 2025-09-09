local Form_Activity108_DialogueCollectionUI = class("Form_Activity108_DialogueCollectionUI", require("UI/Common/HeroActBase/UIHeroActDialogueCollectionBase"))

function Form_Activity108_DialogueCollectionUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity108_DialogueCollectionUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY108_DIALOGUECOLLECTION
end

function Form_Activity108_DialogueCollectionUI:GetFramePrefabName()
  return "Form_Activity108_DialogueCollection"
end

return Form_Activity108_DialogueCollectionUI
