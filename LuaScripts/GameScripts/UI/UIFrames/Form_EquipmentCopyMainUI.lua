local Form_EquipmentCopyMainUI = class("Form_EquipmentCopyMainUI", require("UI/Common/UIBase"))

function Form_EquipmentCopyMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentCopyMainUI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTCOPYMAIN
end

function Form_EquipmentCopyMainUI:GetFramePrefabName()
  return "Form_EquipmentCopyMain"
end

return Form_EquipmentCopyMainUI
