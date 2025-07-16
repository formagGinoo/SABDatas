local Form_ActivityMainUI = class("Form_ActivityMainUI", require("UI/Common/UIBase"))

function Form_ActivityMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYMAIN
end

function Form_ActivityMainUI:GetFramePrefabName()
  return "Form_ActivityMain"
end

return Form_ActivityMainUI
