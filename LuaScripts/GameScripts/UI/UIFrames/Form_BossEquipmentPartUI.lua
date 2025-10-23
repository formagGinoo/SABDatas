local Form_BossEquipmentPartUI = class("Form_BossEquipmentPartUI", require("UI/Common/UIBase"))

function Form_BossEquipmentPartUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_BossEquipmentPartUI:GetID()
  return UIDefines.ID_FORM_BOSSEQUIPMENTPART
end

function Form_BossEquipmentPartUI:GetFramePrefabName()
  return "Form_BossEquipmentPart"
end

return Form_BossEquipmentPartUI
