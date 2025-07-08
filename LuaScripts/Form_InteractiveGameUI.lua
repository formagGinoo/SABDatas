local Form_InteractiveGameUI = class("Form_InteractiveGameUI", require("UI/Common/UIBase"))

function Form_InteractiveGameUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InteractiveGameUI:GetID()
  return UIDefines.ID_FORM_INTERACTIVEGAME
end

function Form_InteractiveGameUI:GetFramePrefabName()
  return "Form_InteractiveGame"
end

return Form_InteractiveGameUI
