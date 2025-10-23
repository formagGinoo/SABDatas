local Form_ActivityReturneeUI = class("Form_ActivityReturneeUI", require("UI/Common/UIBase"))

function Form_ActivityReturneeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityReturneeUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYRETURNEE
end

function Form_ActivityReturneeUI:GetFramePrefabName()
  return "Form_ActivityReturnee"
end

return Form_ActivityReturneeUI
