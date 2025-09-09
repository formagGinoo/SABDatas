local Form_DownloadCleanTipsUI = class("Form_DownloadCleanTipsUI", require("UI/Common/UIBase"))

function Form_DownloadCleanTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_DownloadCleanTipsUI:GetID()
  return UIDefines.ID_FORM_DOWNLOADCLEANTIPS
end

function Form_DownloadCleanTipsUI:GetFramePrefabName()
  return "Form_DownloadCleanTips"
end

return Form_DownloadCleanTipsUI
