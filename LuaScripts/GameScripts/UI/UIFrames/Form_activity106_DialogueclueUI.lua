local Form_activity106_DialogueclueUI = class("Form_activity106_DialogueclueUI", require("UI/Common/UIBase"))

function Form_activity106_DialogueclueUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_activity106_DialogueclueUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY106_DIALOGUECLUE
end

function Form_activity106_DialogueclueUI:GetFramePrefabName()
  return "Form_activity106_Dialogueclue"
end

return Form_activity106_DialogueclueUI
