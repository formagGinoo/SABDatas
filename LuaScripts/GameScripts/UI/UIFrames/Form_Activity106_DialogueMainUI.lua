local Form_Activity106_DialogueMainUI = class("Form_Activity106_DialogueMainUI", require("UI/Common/HeroActBase/UIHeroActDialogueMainBase"))

function Form_Activity106_DialogueMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity106_DialogueMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY106_DIALOGUEMAIN
end

function Form_Activity106_DialogueMainUI:GetFramePrefabName()
  return "Form_Activity106_DialogueMain"
end

return Form_Activity106_DialogueMainUI
