local Form_ActivityMinigame108BattleMainUI = class("Form_ActivityMinigame108BattleMainUI", require("UI/Common/UIBase"))

function Form_ActivityMinigame108BattleMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityMinigame108BattleMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYMINIGAME108BATTLEMAIN
end

function Form_ActivityMinigame108BattleMainUI:GetFramePrefabName()
  return "Form_ActivityMinigame108BattleMain"
end

return Form_ActivityMinigame108BattleMainUI
