local Form_EquipT9ResetUI = class("Form_EquipT9ResetUI", require("UI/Common/UIBase"))

function Form_EquipT9ResetUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipT9ResetUI:GetID()
  return UIDefines.ID_FORM_EQUIPT9RESET
end

function Form_EquipT9ResetUI:GetFramePrefabName()
  return "Form_EquipT9Reset"
end

return Form_EquipT9ResetUI
