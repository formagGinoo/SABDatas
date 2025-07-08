local Form_LoginAnnouncementUI = class("Form_LoginAnnouncementUI", require("UI/Common/UIBase"))

function Form_LoginAnnouncementUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoginAnnouncementUI:GetID()
  return UIDefines.ID_FORM_LOGINANNOUNCEMENT
end

function Form_LoginAnnouncementUI:GetFramePrefabName()
  return "Form_LoginAnnouncement"
end

return Form_LoginAnnouncementUI
