local Form_EquipmentTipsUI = class("Form_EquipmentTipsUI", require("UI/Common/UIBase"))

function Form_EquipmentTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentTipsUI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTTIPS
end

function Form_EquipmentTipsUI:GetFramePrefabName()
  return "Form_EquipmentTips"
end

return Form_EquipmentTipsUI
