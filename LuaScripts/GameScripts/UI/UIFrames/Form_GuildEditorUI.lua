local Form_GuildEditorUI = class("Form_GuildEditorUI", require("UI/Common/UIBase"))

function Form_GuildEditorUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildEditorUI:GetID()
  return UIDefines.ID_FORM_GUILDEDITOR
end

function Form_GuildEditorUI:GetFramePrefabName()
  return "Form_GuildEditor"
end

return Form_GuildEditorUI
