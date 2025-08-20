local Form_PopupTaptapUI = class("Form_PopupTaptapUI", require("UI/Common/UIBase"))

function Form_PopupTaptapUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopupTaptapUI:GetID()
  return UIDefines.ID_FORM_POPUPTAPTAP
end

function Form_PopupTaptapUI:GetFramePrefabName()
  return "Form_PopupTaptap"
end

return Form_PopupTaptapUI
