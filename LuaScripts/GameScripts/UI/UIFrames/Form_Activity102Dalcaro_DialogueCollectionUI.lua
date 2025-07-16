local Form_Activity102Dalcaro_DialogueCollectionUI = class("Form_Activity102Dalcaro_DialogueCollectionUI", require("UI/Common/HeroActBase/UIHeroActDialogueCollectionBase"))

function Form_Activity102Dalcaro_DialogueCollectionUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_DialogueCollectionUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_DIALOGUECOLLECTION
end

function Form_Activity102Dalcaro_DialogueCollectionUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_DialogueCollection"
end

return Form_Activity102Dalcaro_DialogueCollectionUI
