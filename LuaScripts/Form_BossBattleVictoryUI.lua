local Form_BossBattleVictoryUI = class("Form_BossBattleVictoryUI", require("UI/Common/UIBase"))

function Form_BossBattleVictoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BossBattleVictoryUI:GetID()
  return UIDefines.ID_FORM_BOSSBATTLEVICTORY
end

function Form_BossBattleVictoryUI:GetFramePrefabName()
  return "Form_BossBattleVictory"
end

return Form_BossBattleVictoryUI
