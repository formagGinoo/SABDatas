local Form_EquipT10OverloadSuccessfulUI = class("Form_EquipT10OverloadSuccessfulUI", require("UI/Common/UIBase"))

function Form_EquipT10OverloadSuccessfulUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipT10OverloadSuccessfulUI:GetID()
  return UIDefines.ID_FORM_EQUIPT10OVERLOADSUCCESSFUL
end

function Form_EquipT10OverloadSuccessfulUI:GetFramePrefabName()
  return "Form_EquipT10OverloadSuccessful"
end

return Form_EquipT10OverloadSuccessfulUI
