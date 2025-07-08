local Form_ActivityFaceMainUI = class("Form_ActivityFaceMainUI", require("UI/Common/UIBase"))

function Form_ActivityFaceMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityFaceMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYFACEMAIN
end

function Form_ActivityFaceMainUI:GetFramePrefabName()
  return "Form_ActivityFaceMain"
end

return Form_ActivityFaceMainUI
