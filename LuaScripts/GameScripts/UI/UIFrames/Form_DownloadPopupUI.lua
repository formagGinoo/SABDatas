local Form_DownloadPopupUI = class("Form_DownloadPopupUI", require("UI/Common/UIBase"))

function Form_DownloadPopupUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_DownloadPopupUI:GetID()
  return UIDefines.ID_FORM_DOWNLOADPOPUP
end

function Form_DownloadPopupUI:GetFramePrefabName()
  return "Form_DownloadPopup"
end

return Form_DownloadPopupUI
