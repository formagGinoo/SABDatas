local Form_GuildRaidTipUI = class("Form_GuildRaidTipUI", require("UI/Common/UIBase"))

function Form_GuildRaidTipUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildRaidTipUI:GetID()
  return UIDefines.ID_FORM_GUILDRAIDTIP
end

function Form_GuildRaidTipUI:GetFramePrefabName()
  return "Form_GuildRaidTip"
end

return Form_GuildRaidTipUI
