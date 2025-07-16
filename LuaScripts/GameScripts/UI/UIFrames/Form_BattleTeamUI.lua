local Form_BattleTeamUI = class("Form_BattleTeamUI", require("UI/Common/UIBase"))

function Form_BattleTeamUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleTeamUI:GetID()
  return UIDefines.ID_FORM_BATTLETEAM
end

function Form_BattleTeamUI:GetFramePrefabName()
  return "Form_BattleTeam"
end

return Form_BattleTeamUI
