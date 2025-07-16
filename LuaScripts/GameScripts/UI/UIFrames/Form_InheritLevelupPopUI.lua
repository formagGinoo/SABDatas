local Form_InheritLevelupPopUI = class("Form_InheritLevelupPopUI", require("UI/Common/UIBase"))

function Form_InheritLevelupPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InheritLevelupPopUI:GetID()
  return UIDefines.ID_FORM_INHERITLEVELUPPOP
end

function Form_InheritLevelupPopUI:GetFramePrefabName()
  return "Form_InheritLevelupPop"
end

return Form_InheritLevelupPopUI
