local Form_EquipT10Pop2UI = class("Form_EquipT10Pop2UI", require("UI/Common/UIBase"))

function Form_EquipT10Pop2UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipT10Pop2UI:GetID()
  return UIDefines.ID_FORM_EQUIPT10POP2
end

function Form_EquipT10Pop2UI:GetFramePrefabName()
  return "Form_EquipT10Pop2"
end

return Form_EquipT10Pop2UI
