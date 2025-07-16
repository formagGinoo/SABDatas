local Form_PersonalRaidMain_QuickBattleUI = class("Form_PersonalRaidMain_QuickBattleUI", require("UI/Common/UIBase"))

function Form_PersonalRaidMain_QuickBattleUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidMain_QuickBattleUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDMAIN_QUICKBATTLE
end

function Form_PersonalRaidMain_QuickBattleUI:GetFramePrefabName()
  return "Form_PersonalRaidMain_QuickBattle"
end

return Form_PersonalRaidMain_QuickBattleUI
