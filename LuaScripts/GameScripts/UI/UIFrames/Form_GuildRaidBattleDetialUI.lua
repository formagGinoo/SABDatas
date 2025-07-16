local Form_GuildRaidBattleDetialUI = class("Form_GuildRaidBattleDetialUI", require("UI/Common/UIBase"))

function Form_GuildRaidBattleDetialUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildRaidBattleDetialUI:GetID()
  return UIDefines.ID_FORM_GUILDRAIDBATTLEDETIAL
end

function Form_GuildRaidBattleDetialUI:GetFramePrefabName()
  return "Form_GuildRaidBattleDetial"
end

return Form_GuildRaidBattleDetialUI
