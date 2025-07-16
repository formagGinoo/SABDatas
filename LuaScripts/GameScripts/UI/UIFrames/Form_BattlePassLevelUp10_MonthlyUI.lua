local Form_BattlePassLevelUp10_MonthlyUI = class("Form_BattlePassLevelUp10_MonthlyUI", require("UI/Common/BattlePassBase/UIBattlePassLevelUp"))

function Form_BattlePassLevelUp10_MonthlyUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePassLevelUp10_MonthlyUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASSLEVELUP10_MONTHLY
end

function Form_BattlePassLevelUp10_MonthlyUI:GetFramePrefabName()
  return "Form_BattlePassLevelUp10_Monthly"
end

return Form_BattlePassLevelUp10_MonthlyUI
