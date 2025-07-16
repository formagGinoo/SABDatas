local Form_EquipT10OverloadRandomWordUI = class("Form_EquipT10OverloadRandomWordUI", require("UI/Common/UIBase"))

function Form_EquipT10OverloadRandomWordUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipT10OverloadRandomWordUI:GetID()
  return UIDefines.ID_FORM_EQUIPT10OVERLOADRANDOMWORD
end

function Form_EquipT10OverloadRandomWordUI:GetFramePrefabName()
  return "Form_EquipT10OverloadRandomWord"
end

return Form_EquipT10OverloadRandomWordUI
