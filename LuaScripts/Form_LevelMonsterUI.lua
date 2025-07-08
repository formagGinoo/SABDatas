local Form_LevelMonsterUI = class("Form_LevelMonsterUI", require("UI/Common/UIBase"))

function Form_LevelMonsterUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LevelMonsterUI:GetID()
  return UIDefines.ID_FORM_LEVELMONSTER
end

function Form_LevelMonsterUI:GetFramePrefabName()
  return "Form_LevelMonster"
end

return Form_LevelMonsterUI
