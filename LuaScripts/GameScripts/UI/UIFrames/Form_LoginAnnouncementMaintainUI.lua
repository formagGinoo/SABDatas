local Form_LoginAnnouncementMaintainUI = class("Form_LoginAnnouncementMaintainUI", require("UI/Common/UIBase"))

function Form_LoginAnnouncementMaintainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoginAnnouncementMaintainUI:GetID()
  return UIDefines.ID_FORM_LOGINANNOUNCEMENTMAINTAIN
end

function Form_LoginAnnouncementMaintainUI:GetFramePrefabName()
  return "Form_LoginAnnouncementMaintain"
end

return Form_LoginAnnouncementMaintainUI
