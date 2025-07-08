local Form_AttractMain2UI = class("Form_AttractMain2UI", require("UI/Common/UIBase"))

function Form_AttractMain2UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractMain2UI:GetID()
  return UIDefines.ID_FORM_ATTRACTMAIN2
end

function Form_AttractMain2UI:GetFramePrefabName()
  return "Form_AttractMain2"
end

return Form_AttractMain2UI
