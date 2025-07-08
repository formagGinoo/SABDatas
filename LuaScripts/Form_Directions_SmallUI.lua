local Form_Directions_SmallUI = class("Form_Directions_SmallUI", require("UI/Common/UIBase"))

function Form_Directions_SmallUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Directions_SmallUI:GetID()
  return UIDefines.ID_FORM_DIRECTIONS_SMALL
end

function Form_Directions_SmallUI:GetFramePrefabName()
  return "Form_Directions_Small"
end

return Form_Directions_SmallUI
