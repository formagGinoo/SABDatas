local Form_DownloadTipsUI = class("Form_DownloadTipsUI", require("UI/Common/UIBase"))

function Form_DownloadTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_DownloadTipsUI:GetID()
  return UIDefines.ID_FORM_DOWNLOADTIPS
end

function Form_DownloadTipsUI:GetFramePrefabName()
  return "Form_DownloadTips"
end

return Form_DownloadTipsUI
