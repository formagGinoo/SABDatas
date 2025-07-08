local Form_LoginAnnouncementUpgradeUI = class("Form_LoginAnnouncementUpgradeUI", require("UI/Common/UIBase"))

function Form_LoginAnnouncementUpgradeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoginAnnouncementUpgradeUI:GetID()
  return UIDefines.ID_FORM_LOGINANNOUNCEMENTUPGRADE
end

function Form_LoginAnnouncementUpgradeUI:GetFramePrefabName()
  return "Form_LoginAnnouncementUpgrade"
end

return Form_LoginAnnouncementUpgradeUI
