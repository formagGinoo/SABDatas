local Form_RogueAchievementUI = class("Form_RogueAchievementUI", require("UI/Common/UIBase"))

function Form_RogueAchievementUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_RogueAchievementUI:GetID()
  return UIDefines.ID_FORM_ROGUEACHIEVEMENT
end

function Form_RogueAchievementUI:GetFramePrefabName()
  return "Form_RogueAchievement"
end

return Form_RogueAchievementUI
