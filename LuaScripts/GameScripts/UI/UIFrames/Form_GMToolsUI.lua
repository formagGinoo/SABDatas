local Form_GMToolsUI = class("Form_GMToolsUI", require("UI/Common/UIBase"))

function Form_GMToolsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GMToolsUI:GetID()
  return UIDefines.ID_FORM_GMTOOLS
end

function Form_GMToolsUI:GetFramePrefabName()
  return "Form_GMTools"
end

return Form_GMToolsUI
