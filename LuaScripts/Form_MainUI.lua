local Form_MainUI = class("Form_MainUI", require("UI/Common/UIBase"))

function Form_MainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MainUI:GetID()
  return UIDefines.ID_FORM_MAIN
end

function Form_MainUI:GetFramePrefabName()
  return "Form_Main"
end

return Form_MainUI
