local Form_ActExploreExitUI = class("Form_ActExploreExitUI", require("UI/Common/UIBase"))

function Form_ActExploreExitUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActExploreExitUI:GetID()
  return UIDefines.ID_FORM_ACTEXPLOREEXIT
end

function Form_ActExploreExitUI:GetFramePrefabName()
  return "Form_ActExploreExit"
end

return Form_ActExploreExitUI
