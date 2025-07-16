local Form_FilterUI = class("Form_FilterUI", require("UI/Common/UIBase"))

function Form_FilterUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_FilterUI:GetID()
  return UIDefines.ID_FORM_FILTER
end

function Form_FilterUI:GetFramePrefabName()
  return "Form_Filter"
end

return Form_FilterUI
