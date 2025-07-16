local Form_PersonalRaidCopyTeamUI = class("Form_PersonalRaidCopyTeamUI", require("UI/Common/UIBase"))

function Form_PersonalRaidCopyTeamUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidCopyTeamUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDCOPYTEAM
end

function Form_PersonalRaidCopyTeamUI:GetFramePrefabName()
  return "Form_PersonalRaidCopyTeam"
end

return Form_PersonalRaidCopyTeamUI
