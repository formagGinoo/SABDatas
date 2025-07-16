local Form_GuildCalmDownUI = class("Form_GuildCalmDownUI", require("UI/Common/UIBase"))

function Form_GuildCalmDownUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildCalmDownUI:GetID()
  return UIDefines.ID_FORM_GUILDCALMDOWN
end

function Form_GuildCalmDownUI:GetFramePrefabName()
  return "Form_GuildCalmDown"
end

return Form_GuildCalmDownUI
