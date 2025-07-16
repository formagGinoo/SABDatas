local Form_InheritLevelUpSuccessUI = class("Form_InheritLevelUpSuccessUI", require("UI/Common/UIBase"))

function Form_InheritLevelUpSuccessUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InheritLevelUpSuccessUI:GetID()
  return UIDefines.ID_FORM_INHERITLEVELUPSUCCESS
end

function Form_InheritLevelUpSuccessUI:GetFramePrefabName()
  return "Form_InheritLevelUpSuccess"
end

return Form_InheritLevelUpSuccessUI
