local Form_LoginDownloadUI = class("Form_LoginDownloadUI", require("UI/Common/UIBase"))

function Form_LoginDownloadUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoginDownloadUI:GetID()
  return UIDefines.ID_FORM_LOGINDOWNLOAD
end

function Form_LoginDownloadUI:GetFramePrefabName()
  return "Form_LoginDownload"
end

return Form_LoginDownloadUI
