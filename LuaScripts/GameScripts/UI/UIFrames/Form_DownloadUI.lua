local Form_DownloadUI = class("Form_DownloadUI", require("UI/Common/UIBase"))

function Form_DownloadUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_DownloadUI:GetID()
  return UIDefines.ID_FORM_DOWNLOAD
end

function Form_DownloadUI:GetFramePrefabName()
  return "Form_Download"
end

return Form_DownloadUI
