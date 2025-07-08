local Form_PersonalRaidBattleInfoUI = class("Form_PersonalRaidBattleInfoUI", require("UI/Common/UIBase"))

function Form_PersonalRaidBattleInfoUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidBattleInfoUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDBATTLEINFO
end

function Form_PersonalRaidBattleInfoUI:GetFramePrefabName()
  return "Form_PersonalRaidBattleInfo"
end

return Form_PersonalRaidBattleInfoUI
