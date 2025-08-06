local Form_Common_toast_speUI = class("Form_Common_toast_speUI", require("UI/Common/UIBase"))

function Form_Common_toast_speUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Common_toast_speUI:GetID()
  return UIDefines.ID_FORM_COMMON_TOAST_SPE
end

function Form_Common_toast_speUI:GetFramePrefabName()
  return "Form_Common_toast_spe"
end

return Form_Common_toast_speUI
