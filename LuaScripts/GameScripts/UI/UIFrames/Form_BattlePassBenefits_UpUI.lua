local Form_BattlePassBenefits_UpUI = class("Form_BattlePassBenefits_UpUI", require("UI/Common/BattlePassBase/UIBattlePassBenefits"))

function Form_BattlePassBenefits_UpUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePassBenefits_UpUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASSBENEFITS_UP
end

function Form_BattlePassBenefits_UpUI:GetFramePrefabName()
  return "Form_BattlePassBenefits_Up"
end

return Form_BattlePassBenefits_UpUI
