local Form_BattleVictoryUI = class("Form_BattleVictoryUI", require("UI/Common/UIBase"))

function Form_BattleVictoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BattleVictoryUI:GetID()
  return UIDefines.ID_FORM_BATTLEVICTORY
end

function Form_BattleVictoryUI:GetFramePrefabName()
  return "Form_BattleVictory"
end

return Form_BattleVictoryUI
