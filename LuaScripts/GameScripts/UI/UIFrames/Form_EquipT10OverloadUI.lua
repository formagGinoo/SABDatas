local Form_EquipT10OverloadUI = class("Form_EquipT10OverloadUI", require("UI/Common/UIBase"))

function Form_EquipT10OverloadUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipT10OverloadUI:GetID()
  return UIDefines.ID_FORM_EQUIPT10OVERLOAD
end

function Form_EquipT10OverloadUI:GetFramePrefabName()
  return "Form_EquipT10Overload"
end

return Form_EquipT10OverloadUI
