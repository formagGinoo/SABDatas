local Form_BattlePass_MonthlyUI = class("Form_BattlePass_MonthlyUI", require("UI/Common/BattlePassBase/UIBattlePassMain"))

function Form_BattlePass_MonthlyUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePass_MonthlyUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASS_MONTHLY
end

function Form_BattlePass_MonthlyUI:GetFramePrefabName()
  return "Form_BattlePass_Monthly"
end

return Form_BattlePass_MonthlyUI
