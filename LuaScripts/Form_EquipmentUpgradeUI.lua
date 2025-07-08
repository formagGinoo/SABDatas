local Form_EquipmentUpgradeUI = class("Form_EquipmentUpgradeUI", require("UI/Common/UIBase"))

function Form_EquipmentUpgradeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentUpgradeUI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTUPGRADE
end

function Form_EquipmentUpgradeUI:GetFramePrefabName()
  return "Form_EquipmentUpgrade"
end

return Form_EquipmentUpgradeUI
