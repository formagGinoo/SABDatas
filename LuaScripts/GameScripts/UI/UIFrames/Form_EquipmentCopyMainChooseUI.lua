local Form_EquipmentCopyMainChooseUI = class("Form_EquipmentCopyMainChooseUI", require("UI/Common/UIBase"))

function Form_EquipmentCopyMainChooseUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipmentCopyMainChooseUI:GetID()
  return UIDefines.ID_FORM_EQUIPMENTCOPYMAINCHOOSE
end

function Form_EquipmentCopyMainChooseUI:GetFramePrefabName()
  return "Form_EquipmentCopyMainChoose"
end

return Form_EquipmentCopyMainChooseUI
