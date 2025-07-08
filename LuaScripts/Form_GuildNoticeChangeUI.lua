local Form_GuildNoticeChangeUI = class("Form_GuildNoticeChangeUI", require("UI/Common/UIBase"))

function Form_GuildNoticeChangeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildNoticeChangeUI:GetID()
  return UIDefines.ID_FORM_GUILDNOTICECHANGE
end

function Form_GuildNoticeChangeUI:GetFramePrefabName()
  return "Form_GuildNoticeChange"
end

return Form_GuildNoticeChangeUI
