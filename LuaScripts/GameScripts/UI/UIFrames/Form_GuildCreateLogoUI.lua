local Form_GuildCreateLogoUI = class("Form_GuildCreateLogoUI", require("UI/Common/UIBase"))

function Form_GuildCreateLogoUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildCreateLogoUI:GetID()
  return UIDefines.ID_FORM_GUILDCREATELOGO
end

function Form_GuildCreateLogoUI:GetFramePrefabName()
  return "Form_GuildCreateLogo"
end

return Form_GuildCreateLogoUI
