local Form_EquipmentUpgradeTipsUI = class("Form_EquipmentUpgradeTipsUI", require("UI/Common/UIBase"))

function Form_EquipmentUpgradeTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentUpgradeTipsUI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTUPGRADETIPS
end

function Form_EquipmentUpgradeTipsUI:GetFramePrefabName()
  return "Form_EquipmentUpgradeTips"
end

return Form_EquipmentUpgradeTipsUI
