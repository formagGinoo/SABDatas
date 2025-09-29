local Form_InheritLevelQuickUpResultUI = class("Form_InheritLevelQuickUpResultUI", require("UI/Common/UIBase"))

function Form_InheritLevelQuickUpResultUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InheritLevelQuickUpResultUI:GetID()
  return UIDefines.ID_FORM_INHERITLEVELQUICKUPRESULT
end

function Form_InheritLevelQuickUpResultUI:GetFramePrefabName()
  return "Form_InheritLevelQuickUpResult"
end

return Form_InheritLevelQuickUpResultUI
