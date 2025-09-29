local Form_SpineInteractUI = class("Form_SpineInteractUI", require("UI/Common/UIBase"))

function Form_SpineInteractUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_SpineInteractUI:GetID()
  return UIDefines.ID_FORM_SPINEINTERACT
end

function Form_SpineInteractUI:GetFramePrefabName()
  return "Form_SpineInteract"
end

return Form_SpineInteractUI
