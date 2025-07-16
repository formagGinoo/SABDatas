local Form_RogueBattleVictoryUI = class("Form_RogueBattleVictoryUI", require("UI/Common/UIBase"))

function Form_RogueBattleVictoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RogueBattleVictoryUI:GetID()
  return UIDefines.ID_FORM_ROGUEBATTLEVICTORY
end

function Form_RogueBattleVictoryUI:GetFramePrefabName()
  return "Form_RogueBattleVictory"
end

return Form_RogueBattleVictoryUI
