local Form_PersonalCardUI = class("Form_PersonalCardUI", require("UI/Common/UIBase"))

function Form_PersonalCardUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalCardUI:GetID()
  return UIDefines.ID_FORM_PERSONALCARD
end

function Form_PersonalCardUI:GetFramePrefabName()
  return "Form_PersonalCard"
end

return Form_PersonalCardUI
