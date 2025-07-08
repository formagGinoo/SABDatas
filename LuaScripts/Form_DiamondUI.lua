local Form_DiamondUI = class("Form_DiamondUI", require("UI/Common/UIBase"))

function Form_DiamondUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_DiamondUI:GetID()
  return UIDefines.ID_FORM_DIAMOND
end

function Form_DiamondUI:GetFramePrefabName()
  return "Form_Diamond"
end

return Form_DiamondUI
