local Form_Activity105_DialogueCollectionUI = class("Form_Activity105_DialogueCollectionUI", require("UI/Common/HeroActBase/UIHeroActDialogueCollectionBase"))

function Form_Activity105_DialogueCollectionUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105_DialogueCollectionUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105_DIALOGUECOLLECTION
end

function Form_Activity105_DialogueCollectionUI:GetFramePrefabName()
  return "Form_Activity105_DialogueCollection"
end

return Form_Activity105_DialogueCollectionUI
