local Form_HallActivityMainUI = class("Form_HallActivityMainUI", require("UI/Common/UIBase"))

function Form_HallActivityMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HallActivityMainUI:GetID()
  return UIDefines.ID_FORM_HALLACTIVITYMAIN
end

function Form_HallActivityMainUI:GetFramePrefabName()
  return "Form_HallActivityMain"
end

return Form_HallActivityMainUI
