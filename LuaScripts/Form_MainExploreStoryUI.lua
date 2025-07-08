local Form_MainExploreStoryUI = class("Form_MainExploreStoryUI", require("UI/Common/UIBase"))

function Form_MainExploreStoryUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MainExploreStoryUI:GetID()
  return UIDefines.ID_FORM_MAINEXPLORESTORY
end

function Form_MainExploreStoryUI:GetFramePrefabName()
  return "Form_MainExploreStory"
end

return Form_MainExploreStoryUI
