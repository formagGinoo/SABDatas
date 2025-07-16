local Form_BattlePassLevelUpPopUI = class("Form_BattlePassLevelUpPopUI", require("UI/Common/UIBase"))

function Form_BattlePassLevelUpPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePassLevelUpPopUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASSLEVELUPPOP
end

function Form_BattlePassLevelUpPopUI:GetFramePrefabName()
  return "Form_BattlePassLevelUpPop"
end

return Form_BattlePassLevelUpPopUI
