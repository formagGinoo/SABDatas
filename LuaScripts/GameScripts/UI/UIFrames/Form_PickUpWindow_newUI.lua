local Form_PickUpWindow_newUI = class("Form_PickUpWindow_newUI", require("UI/Common/UIBase"))

function Form_PickUpWindow_newUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PickUpWindow_newUI:GetID()
  return UIDefines.ID_FORM_PICKUPWINDOW_NEW
end

function Form_PickUpWindow_newUI:GetFramePrefabName()
  return "Form_PickUpWindow_new"
end

return Form_PickUpWindow_newUI
