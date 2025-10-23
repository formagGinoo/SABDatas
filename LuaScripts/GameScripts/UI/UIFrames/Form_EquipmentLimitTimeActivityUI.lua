local Form_EquipmentLimitTimeActivityUI = class("Form_EquipmentLimitTimeActivityUI", require("UI/Common/UIBase"))

function Form_EquipmentLimitTimeActivityUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentLimitTimeActivityUI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTLIMITTIMEACTIVITY
end

function Form_EquipmentLimitTimeActivityUI:GetFramePrefabName()
  return "Form_EquipmentLimitTimeActivity"
end

return Form_EquipmentLimitTimeActivityUI
