local Form_Directions_BigUI = class("Form_Directions_BigUI", require("UI/Common/UIBase"))

function Form_Directions_BigUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Directions_BigUI:GetID()
  return UIDefines.ID_FORM_DIRECTIONS_BIG
end

function Form_Directions_BigUI:GetFramePrefabName()
  return "Form_Directions_Big"
end

return Form_Directions_BigUI
