local Form_BattlePassLevelUp10_UpUI = class("Form_BattlePassLevelUp10_UpUI", require("UI/Common/BattlePassBase/UIBattlePassLevelUp"))

function Form_BattlePassLevelUp10_UpUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePassLevelUp10_UpUI:GetID()
  return UIDefines.ID_FORM_BATTLEPASSLEVELUP10_UP
end

function Form_BattlePassLevelUp10_UpUI:GetFramePrefabName()
  return "Form_BattlePassLevelUp10_Up"
end

return Form_BattlePassLevelUp10_UpUI
