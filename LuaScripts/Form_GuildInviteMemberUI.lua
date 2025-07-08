local Form_GuildInviteMemberUI = class("Form_GuildInviteMemberUI", require("UI/Common/UIBase"))

function Form_GuildInviteMemberUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildInviteMemberUI:GetID()
  return UIDefines.ID_FORM_GUILDINVITEMEMBER
end

function Form_GuildInviteMemberUI:GetFramePrefabName()
  return "Form_GuildInviteMember"
end

return Form_GuildInviteMemberUI
