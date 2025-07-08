local Form_PvpBattleVictoryUI = class("Form_PvpBattleVictoryUI", require("UI/Common/UIBase"))

function Form_PvpBattleVictoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpBattleVictoryUI:GetID()
  return UIDefines.ID_FORM_PVPBATTLEVICTORY
end

function Form_PvpBattleVictoryUI:GetFramePrefabName()
  return "Form_PvpBattleVictory"
end

return Form_PvpBattleVictoryUI
