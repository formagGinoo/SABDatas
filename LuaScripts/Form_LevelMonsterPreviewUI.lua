local Form_LevelMonsterPreviewUI = class("Form_LevelMonsterPreviewUI", require("UI/Common/UIBase"))

function Form_LevelMonsterPreviewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LevelMonsterPreviewUI:GetID()
  return UIDefines.ID_FORM_LEVELMONSTERPREVIEW
end

function Form_LevelMonsterPreviewUI:GetFramePrefabName()
  return "Form_LevelMonsterPreview"
end

return Form_LevelMonsterPreviewUI
