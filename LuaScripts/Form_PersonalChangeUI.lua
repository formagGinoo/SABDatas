local Form_PersonalChangeUI = class("Form_PersonalChangeUI", require("UI/Common/UIBase"))

function Form_PersonalChangeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalChangeUI:GetID()
  return UIDefines.ID_FORM_PERSONALCHANGE
end

function Form_PersonalChangeUI:GetFramePrefabName()
  return "Form_PersonalChange"
end

return Form_PersonalChangeUI
