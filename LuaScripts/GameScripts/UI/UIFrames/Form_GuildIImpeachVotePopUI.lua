local Form_GuildIImpeachVotePopUI = class("Form_GuildIImpeachVotePopUI", require("UI/Common/UIBase"))

function Form_GuildIImpeachVotePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuildIImpeachVotePopUI:GetID()
  return UIDefines.ID_FORM_GUILDIIMPEACHVOTEPOP
end

function Form_GuildIImpeachVotePopUI:GetFramePrefabName()
  return "Form_GuildIImpeachVotePop"
end

return Form_GuildIImpeachVotePopUI
