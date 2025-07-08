local Form_PersonalRaidMain_BattleresultUI = class("Form_PersonalRaidMain_BattleresultUI", require("UI/Common/UIBase"))

function Form_PersonalRaidMain_BattleresultUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidMain_BattleresultUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDMAIN_BATTLERESULT
end

function Form_PersonalRaidMain_BattleresultUI:GetFramePrefabName()
  return "Form_PersonalRaidMain_Battleresult"
end

return Form_PersonalRaidMain_BattleresultUI
