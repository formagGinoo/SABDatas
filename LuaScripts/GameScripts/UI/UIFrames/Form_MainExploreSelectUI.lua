local Form_MainExploreSelectUI = class("Form_MainExploreSelectUI", require("UI/Common/UIBase"))

function Form_MainExploreSelectUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MainExploreSelectUI:GetID()
  return UIDefines.ID_FORM_MAINEXPLORESELECT
end

function Form_MainExploreSelectUI:GetFramePrefabName()
  return "Form_MainExploreSelect"
end

return Form_MainExploreSelectUI
