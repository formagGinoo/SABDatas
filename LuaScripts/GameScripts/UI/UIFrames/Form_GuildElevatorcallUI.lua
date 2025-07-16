local Form_GuildElevatorcallUI = class("Form_GuildElevatorcallUI", require("UI/Common/UIBase"))

function Form_GuildElevatorcallUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildElevatorcallUI:GetID()
  return UIDefines.ID_FORM_GUILDELEVATORCALL
end

function Form_GuildElevatorcallUI:GetFramePrefabName()
  return "Form_GuildElevatorcall"
end

return Form_GuildElevatorcallUI
