local Form_EquipmentCopyMainChoose2UI = class("Form_EquipmentCopyMainChoose2UI", require("UI/Common/UIBase"))

function Form_EquipmentCopyMainChoose2UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentCopyMainChoose2UI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE2
end

function Form_EquipmentCopyMainChoose2UI:GetFramePrefabName()
  return "Form_EquipmentCopyMainChoose2"
end

return Form_EquipmentCopyMainChoose2UI
