local Form_GuildRaidMainUI = class("Form_GuildRaidMainUI", require("UI/Common/UIBase"))

function Form_GuildRaidMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildRaidMainUI:GetID()
  return UIDefines.ID_FORM_GUILDRAIDMAIN
end

function Form_GuildRaidMainUI:GetFramePrefabName()
  return "Form_GuildRaidMain"
end

return Form_GuildRaidMainUI
