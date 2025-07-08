local Form_PopupTaskUI = class("Form_PopupTaskUI", require("UI/Common/UIBase"))

function Form_PopupTaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PopupTaskUI:GetID()
  return UIDefines.ID_FORM_POPUPTASK
end

function Form_PopupTaskUI:GetFramePrefabName()
  return "Form_PopupTask"
end

return Form_PopupTaskUI
