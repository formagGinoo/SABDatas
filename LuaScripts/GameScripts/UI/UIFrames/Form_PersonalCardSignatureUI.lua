local Form_PersonalCardSignatureUI = class("Form_PersonalCardSignatureUI", require("UI/Common/UIBase"))

function Form_PersonalCardSignatureUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalCardSignatureUI:GetID()
  return UIDefines.ID_FORM_PERSONALCARDSIGNATURE
end

function Form_PersonalCardSignatureUI:GetFramePrefabName()
  return "Form_PersonalCardSignature"
end

return Form_PersonalCardSignatureUI
