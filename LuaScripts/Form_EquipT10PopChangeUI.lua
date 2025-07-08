local Form_EquipT10PopChangeUI = class("Form_EquipT10PopChangeUI", require("UI/Common/UIBase"))

function Form_EquipT10PopChangeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipT10PopChangeUI:GetID()
  return UIDefines.ID_FORM_EQUIPT10POPCHANGE
end

function Form_EquipT10PopChangeUI:GetFramePrefabName()
  return "Form_EquipT10PopChange"
end

return Form_EquipT10PopChangeUI
