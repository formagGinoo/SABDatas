local Form_GuildUI = class("Form_GuildUI", require("UI/Common/UIBase"))

function Form_GuildUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildUI:GetID()
  return UIDefines.ID_FORM_GUILD
end

function Form_GuildUI:GetFramePrefabName()
  return "Form_Guild"
end

return Form_GuildUI
