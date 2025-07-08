local Form_GuildRaidRecordListUI = class("Form_GuildRaidRecordListUI", require("UI/Common/UIBase"))

function Form_GuildRaidRecordListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildRaidRecordListUI:GetID()
  return UIDefines.ID_FORM_GUILDRAIDRECORDLIST
end

function Form_GuildRaidRecordListUI:GetFramePrefabName()
  return "Form_GuildRaidRecordList"
end

return Form_GuildRaidRecordListUI
