local Form_EquipmentResolveUI = class("Form_EquipmentResolveUI", require("UI/Common/UIBase"))

function Form_EquipmentResolveUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentResolveUI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTRESOLVE
end

function Form_EquipmentResolveUI:GetFramePrefabName()
  return "Form_EquipmentResolve"
end

return Form_EquipmentResolveUI
