local Form_Activity103Luoleilai_DialogueCollectionUI = class("Form_Activity103Luoleilai_DialogueCollectionUI", require("UI/Common/HeroActBase/UIHeroActDialogueCollectionBase"))

function Form_Activity103Luoleilai_DialogueCollectionUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity103Luoleilai_DialogueCollectionUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_DIALOGUECOLLECTION
end

function Form_Activity103Luoleilai_DialogueCollectionUI:GetFramePrefabName()
  return "Form_Activity103Luoleilai_DialogueCollection"
end

return Form_Activity103Luoleilai_DialogueCollectionUI
