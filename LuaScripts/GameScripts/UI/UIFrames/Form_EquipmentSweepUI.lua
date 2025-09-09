local Form_EquipmentSweepUI = class("Form_EquipmentSweepUI", require("UI/Common/UIBase"))

function Form_EquipmentSweepUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentSweepUI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTSWEEP
end

function Form_EquipmentSweepUI:GetFramePrefabName()
  return "Form_EquipmentSweep"
end

return Form_EquipmentSweepUI
