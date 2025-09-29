local Form_Activity110MiniGameBattleMainUI = class("Form_Activity110MiniGameBattleMainUI", require("UI/Common/UIBase"))

function Form_Activity110MiniGameBattleMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110MiniGameBattleMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110MINIGAMEBATTLEMAIN
end

function Form_Activity110MiniGameBattleMainUI:GetFramePrefabName()
  return "Form_Activity110MiniGameBattleMain"
end

return Form_Activity110MiniGameBattleMainUI
