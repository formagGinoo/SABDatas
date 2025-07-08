local Form_EquipT10Pop1UI = class("Form_EquipT10Pop1UI", require("UI/Common/UIBase"))

function Form_EquipT10Pop1UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipT10Pop1UI:GetID()
  return UIDefines.ID_FORM_EQUIPT10POP1
end

function Form_EquipT10Pop1UI:GetFramePrefabName()
  return "Form_EquipT10Pop1"
end

return Form_EquipT10Pop1UI
