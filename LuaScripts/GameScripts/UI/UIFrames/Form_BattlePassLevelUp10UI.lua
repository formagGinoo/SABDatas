local Form_BattlePassLevelUp10UI = class("Form_BattlePassLevelUp10UI", require("UI/Common/BattlePassBase/UIBattlePassLevelUp"))

function Form_BattlePassLevelUp10UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattlePassLevelUp10UI:GetID()
  return UIDefines.ID_FORM_BATTLEPASSLEVELUP10
end

function Form_BattlePassLevelUp10UI:GetFramePrefabName()
  return "Form_BattlePassLevelUp10"
end

return Form_BattlePassLevelUp10UI
