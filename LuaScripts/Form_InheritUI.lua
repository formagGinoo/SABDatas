local Form_InheritUI = class("Form_InheritUI", require("UI/Common/UIBase"))

function Form_InheritUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InheritUI:GetID()
  return UIDefines.ID_FORM_INHERIT
end

function Form_InheritUI:GetFramePrefabName()
  return "Form_Inherit"
end

return Form_InheritUI
