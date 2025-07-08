local Form_InheritLevelUpUI = class("Form_InheritLevelUpUI", require("UI/Common/UIBase"))

function Form_InheritLevelUpUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InheritLevelUpUI:GetID()
  return UIDefines.ID_FORM_INHERITLEVELUP
end

function Form_InheritLevelUpUI:GetFramePrefabName()
  return "Form_InheritLevelUp"
end

return Form_InheritLevelUpUI
