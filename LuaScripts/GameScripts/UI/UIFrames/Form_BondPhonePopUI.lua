local Form_BondPhonePopUI = class("Form_BondPhonePopUI", require("UI/Common/UIBase"))

function Form_BondPhonePopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BondPhonePopUI:GetID()
  return UIDefines.ID_FORM_BONDPHONEPOP
end

function Form_BondPhonePopUI:GetFramePrefabName()
  return "Form_BondPhonePop"
end

return Form_BondPhonePopUI
