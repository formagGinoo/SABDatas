local Form_GuildMessageEditorPopUI = class("Form_GuildMessageEditorPopUI", require("UI/Common/UIBase"))

function Form_GuildMessageEditorPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildMessageEditorPopUI:GetID()
  return UIDefines.ID_FORM_GUILDMESSAGEEDITORPOP
end

function Form_GuildMessageEditorPopUI:GetFramePrefabName()
  return "Form_GuildMessageEditorPop"
end

return Form_GuildMessageEditorPopUI
