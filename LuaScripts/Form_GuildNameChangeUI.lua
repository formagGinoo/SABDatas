local Form_GuildNameChangeUI = class("Form_GuildNameChangeUI", require("UI/Common/UIBase"))

function Form_GuildNameChangeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildNameChangeUI:GetID()
  return UIDefines.ID_FORM_GUILDNAMECHANGE
end

function Form_GuildNameChangeUI:GetFramePrefabName()
  return "Form_GuildNameChange"
end

return Form_GuildNameChangeUI
