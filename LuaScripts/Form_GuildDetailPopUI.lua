local Form_GuildDetailPopUI = class("Form_GuildDetailPopUI", require("UI/Common/UIBase"))

function Form_GuildDetailPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildDetailPopUI:GetID()
  return UIDefines.ID_FORM_GUILDDETAILPOP
end

function Form_GuildDetailPopUI:GetFramePrefabName()
  return "Form_GuildDetailPop"
end

return Form_GuildDetailPopUI
