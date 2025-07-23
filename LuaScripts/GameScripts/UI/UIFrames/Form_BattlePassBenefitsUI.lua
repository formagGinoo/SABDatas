local Form_BattlePassBenefitsUI = class("Form_BattlePassBenefitsUI", require("UI/Common/BattlePassBase/UIBattlePassBenefits"))

function Form_BattlePassBenefitsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePassBenefitsUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASSBENEFITS
end

function Form_BattlePassBenefitsUI:GetFramePrefabName()
  return "Form_BattlePassBenefits"
end

return Form_BattlePassBenefitsUI
