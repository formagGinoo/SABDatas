local Form_PickUpWindowUI = class("Form_PickUpWindowUI", require("UI/Common/UIBase"))

function Form_PickUpWindowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PickUpWindowUI:GetID()
  return UIDefines.ID_FORM_PICKUPWINDOW
end

function Form_PickUpWindowUI:GetFramePrefabName()
  return "Form_PickUpWindow"
end

return Form_PickUpWindowUI
