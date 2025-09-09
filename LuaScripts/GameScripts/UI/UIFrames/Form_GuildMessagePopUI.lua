local Form_GuildMessagePopUI = class("Form_GuildMessagePopUI", require("UI/Common/UIBase"))

function Form_GuildMessagePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildMessagePopUI:GetID()
  return UIDefines.ID_FORM_GUILDMESSAGEPOP
end

function Form_GuildMessagePopUI:GetFramePrefabName()
  return "Form_GuildMessagePop"
end

return Form_GuildMessagePopUI
