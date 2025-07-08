local Form_MainExploreRemenberUI = class("Form_MainExploreRemenberUI", require("UI/Common/UIBase"))

function Form_MainExploreRemenberUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MainExploreRemenberUI:GetID()
  return UIDefines.ID_FORM_MAINEXPLOREREMENBER
end

function Form_MainExploreRemenberUI:GetFramePrefabName()
  return "Form_MainExploreRemenber"
end

return Form_MainExploreRemenberUI
