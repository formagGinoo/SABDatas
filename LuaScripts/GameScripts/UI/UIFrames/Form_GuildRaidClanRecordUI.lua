local Form_GuildRaidClanRecordUI = class("Form_GuildRaidClanRecordUI", require("UI/Common/UIBase"))

function Form_GuildRaidClanRecordUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildRaidClanRecordUI:GetID()
  return UIDefines.ID_FORM_GUILDRAIDCLANRECORD
end

function Form_GuildRaidClanRecordUI:GetFramePrefabName()
  return "Form_GuildRaidClanRecord"
end

return Form_GuildRaidClanRecordUI
