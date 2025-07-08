local Form_PvpReplaceBattleVictoryUI = class("Form_PvpReplaceBattleVictoryUI", require("UI/Common/UIBase"))

function Form_PvpReplaceBattleVictoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PvpReplaceBattleVictoryUI:GetID()
  return UIDefines.ID_FORM_PVPREPLACEBATTLEVICTORY
end

function Form_PvpReplaceBattleVictoryUI:GetFramePrefabName()
  return "Form_PvpReplaceBattleVictory"
end

return Form_PvpReplaceBattleVictoryUI
