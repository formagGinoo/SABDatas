local Form_GuildCreateUI = class("Form_GuildCreateUI", require("UI/Common/UIBase"))

function Form_GuildCreateUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildCreateUI:GetID()
  return UIDefines.ID_FORM_GUILDCREATE
end

function Form_GuildCreateUI:GetFramePrefabName()
  return "Form_GuildCreate"
end

return Form_GuildCreateUI
