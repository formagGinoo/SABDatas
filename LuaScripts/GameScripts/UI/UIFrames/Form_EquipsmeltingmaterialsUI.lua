local Form_EquipsmeltingmaterialsUI = class("Form_EquipsmeltingmaterialsUI", require("UI/Common/UIBase"))

function Form_EquipsmeltingmaterialsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_EquipsmeltingmaterialsUI:GetID()
  return UIDefines.ID_FORM_EQUIPSMELTINGMATERIALS
end

function Form_EquipsmeltingmaterialsUI:GetFramePrefabName()
  return "Form_Equipsmeltingmaterials"
end

return Form_EquipsmeltingmaterialsUI
