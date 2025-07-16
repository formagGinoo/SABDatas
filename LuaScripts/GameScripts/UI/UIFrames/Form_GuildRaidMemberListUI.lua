local Form_GuildRaidMemberListUI = class("Form_GuildRaidMemberListUI", require("UI/Common/UIBase"))

function Form_GuildRaidMemberListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildRaidMemberListUI:GetID()
  return UIDefines.ID_FORM_GUILDRAIDMEMBERLIST
end

function Form_GuildRaidMemberListUI:GetFramePrefabName()
  return "Form_GuildRaidMemberList"
end

return Form_GuildRaidMemberListUI
