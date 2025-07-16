local Form_GuildManagePopUI = class("Form_GuildManagePopUI", require("UI/Common/UIBase"))

function Form_GuildManagePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildManagePopUI:GetID()
  return UIDefines.ID_FORM_GUILDMANAGEPOP
end

function Form_GuildManagePopUI:GetFramePrefabName()
  return "Form_GuildManagePop"
end

return Form_GuildManagePopUI
