local Form_GuildRaidRanKChangeTipsUI = class("Form_GuildRaidRanKChangeTipsUI", require("UI/Common/UIBase"))

function Form_GuildRaidRanKChangeTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildRaidRanKChangeTipsUI:GetID()
  return UIDefines.ID_FORM_GUILDRAIDRANKCHANGETIPS
end

function Form_GuildRaidRanKChangeTipsUI:GetFramePrefabName()
  return "Form_GuildRaidRanKChangeTips"
end

return Form_GuildRaidRanKChangeTipsUI
