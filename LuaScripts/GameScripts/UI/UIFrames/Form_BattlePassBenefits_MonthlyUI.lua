local Form_BattlePassBenefits_MonthlyUI = class("Form_BattlePassBenefits_MonthlyUI", require("UI/Common/BattlePassBase/UIBattlePassBenefits"))

function Form_BattlePassBenefits_MonthlyUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePassBenefits_MonthlyUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASSBENEFITS_MONTHLY
end

function Form_BattlePassBenefits_MonthlyUI:GetFramePrefabName()
  return "Form_BattlePassBenefits_Monthly"
end

return Form_BattlePassBenefits_MonthlyUI
