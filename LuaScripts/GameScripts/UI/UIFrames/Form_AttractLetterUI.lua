local Form_AttractLetterUI = class("Form_AttractLetterUI", require("UI/Common/UIBase"))

function Form_AttractLetterUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractLetterUI:GetID()
  return UIDefines.ID_FORM_ATTRACTLETTER
end

function Form_AttractLetterUI:GetFramePrefabName()
  return "Form_AttractLetter"
end

return Form_AttractLetterUI
