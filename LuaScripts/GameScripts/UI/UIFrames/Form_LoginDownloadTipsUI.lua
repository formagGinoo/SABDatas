local Form_LoginDownloadTipsUI = class("Form_LoginDownloadTipsUI", require("UI/Common/UIBase"))

function Form_LoginDownloadTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoginDownloadTipsUI:GetID()
  return UIDefines.ID_FORM_LOGINDOWNLOADTIPS
end

function Form_LoginDownloadTipsUI:GetFramePrefabName()
  return "Form_LoginDownloadTips"
end

return Form_LoginDownloadTipsUI
