local Form_ActExploreMainUI = class("Form_ActExploreMainUI", require("UI/Common/UIBase"))

function Form_ActExploreMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActExploreMainUI:GetID()
  return UIDefines.ID_FORM_ACTEXPLOREMAIN
end

function Form_ActExploreMainUI:GetFramePrefabName()
  return "Form_ActExploreMain"
end

return Form_ActExploreMainUI
