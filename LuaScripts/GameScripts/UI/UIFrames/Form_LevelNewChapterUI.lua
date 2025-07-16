local Form_LevelNewChapterUI = class("Form_LevelNewChapterUI", require("UI/Common/UIBase"))

function Form_LevelNewChapterUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LevelNewChapterUI:GetID()
  return UIDefines.ID_FORM_LEVELNEWCHAPTER
end

function Form_LevelNewChapterUI:GetFramePrefabName()
  return "Form_LevelNewChapter"
end

return Form_LevelNewChapterUI
