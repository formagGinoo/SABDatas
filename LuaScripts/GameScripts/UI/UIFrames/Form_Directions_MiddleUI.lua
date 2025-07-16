local Form_Directions_MiddleUI = class("Form_Directions_MiddleUI", require("UI/Common/UIBase"))

function Form_Directions_MiddleUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Directions_MiddleUI:GetID()
  return UIDefines.ID_FORM_DIRECTIONS_MIDDLE
end

function Form_Directions_MiddleUI:GetFramePrefabName()
  return "Form_Directions_Middle"
end

return Form_Directions_MiddleUI
