local Form_GuildRaidRankPopUI = class("Form_GuildRaidRankPopUI", require("UI/Common/UIBase"))

function Form_GuildRaidRankPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildRaidRankPopUI:GetID()
  return UIDefines.ID_FORM_GUILDRAIDRANKPOP
end

function Form_GuildRaidRankPopUI:GetFramePrefabName()
  return "Form_GuildRaidRankPop"
end

return Form_GuildRaidRankPopUI
