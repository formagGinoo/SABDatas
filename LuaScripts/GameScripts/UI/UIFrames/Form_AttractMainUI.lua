local Form_AttractMainUI = class("Form_AttractMainUI", require("UI/Common/UIBase"))

function Form_AttractMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_AttractMainUI:GetID()
  return UIDefines.ID_FORM_ATTRACTMAIN
end

function Form_AttractMainUI:GetFramePrefabName()
  return "Form_AttractMain"
end

return Form_AttractMainUI
