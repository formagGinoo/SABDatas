local Form_GuildListUI = class("Form_GuildListUI", require("UI/Common/UIBase"))

function Form_GuildListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildListUI:GetID()
  return UIDefines.ID_FORM_GUILDLIST
end

function Form_GuildListUI:GetFramePrefabName()
  return "Form_GuildList"
end

return Form_GuildListUI
