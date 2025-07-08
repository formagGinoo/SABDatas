local Form_LevelMainUI = class("Form_LevelMainUI", require("UI/Common/UIBase"))

function Form_LevelMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LevelMainUI:GetID()
  return UIDefines.ID_FORM_LEVELMAIN
end

function Form_LevelMainUI:GetFramePrefabName()
  return "Form_LevelMain"
end

return Form_LevelMainUI
