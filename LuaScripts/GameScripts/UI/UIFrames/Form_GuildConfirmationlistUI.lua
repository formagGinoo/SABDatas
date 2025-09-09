local Form_GuildConfirmationlistUI = class("Form_GuildConfirmationlistUI", require("UI/Common/UIBase"))

function Form_GuildConfirmationlistUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildConfirmationlistUI:GetID()
  return UIDefines.ID_FORM_GUILDCONFIRMATIONLIST
end

function Form_GuildConfirmationlistUI:GetFramePrefabName()
  return "Form_GuildConfirmationlist"
end

return Form_GuildConfirmationlistUI
