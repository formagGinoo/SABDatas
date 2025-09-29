local Form_InheritLevelQuickupUI = class("Form_InheritLevelQuickupUI", require("UI/Common/UIBase"))

function Form_InheritLevelQuickupUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InheritLevelQuickupUI:GetID()
  return UIDefines.ID_FORM_INHERITLEVELQUICKUP
end

function Form_InheritLevelQuickupUI:GetFramePrefabName()
  return "Form_InheritLevelQuickup"
end

return Form_InheritLevelQuickupUI
