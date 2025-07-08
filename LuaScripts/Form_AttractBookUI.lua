local Form_AttractBookUI = class("Form_AttractBookUI", require("UI/Common/UIBase"))

function Form_AttractBookUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractBookUI:GetID()
  return UIDefines.ID_FORM_ATTRACTBOOK
end

function Form_AttractBookUI:GetFramePrefabName()
  return "Form_AttractBook"
end

return Form_AttractBookUI
