local Form_AttractBook2UI = class("Form_AttractBook2UI", require("UI/Common/UIBase"))

function Form_AttractBook2UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractBook2UI:GetID()
  return UIDefines.ID_FORM_ATTRACTBOOK2
end

function Form_AttractBook2UI:GetFramePrefabName()
  return "Form_AttractBook2"
end

return Form_AttractBook2UI
