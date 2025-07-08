local Form_GuildSignUI = class("Form_GuildSignUI", require("UI/Common/UIBase"))

function Form_GuildSignUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildSignUI:GetID()
  return UIDefines.ID_FORM_GUILDSIGN
end

function Form_GuildSignUI:GetFramePrefabName()
  return "Form_GuildSign"
end

return Form_GuildSignUI
