local Form_GuildRaidBossRoundTipsUI = class("Form_GuildRaidBossRoundTipsUI", require("UI/Common/UIBase"))

function Form_GuildRaidBossRoundTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildRaidBossRoundTipsUI:GetID()
  return UIDefines.ID_FORM_GUILDRAIDBOSSROUNDTIPS
end

function Form_GuildRaidBossRoundTipsUI:GetFramePrefabName()
  return "Form_GuildRaidBossRoundTips"
end

return Form_GuildRaidBossRoundTipsUI
