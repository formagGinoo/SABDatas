local Form_GuildMemberInfoPopUI = class("Form_GuildMemberInfoPopUI", require("UI/Common/UIBase"))

function Form_GuildMemberInfoPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildMemberInfoPopUI:GetID()
  return UIDefines.ID_FORM_GUILDMEMBERINFOPOP
end

function Form_GuildMemberInfoPopUI:GetFramePrefabName()
  return "Form_GuildMemberInfoPop"
end

return Form_GuildMemberInfoPopUI
