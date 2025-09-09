local Form_LoginInstallPopUI = class("Form_LoginInstallPopUI", require("UI/Common/UIBase"))

function Form_LoginInstallPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_LoginInstallPopUI:GetID()
  return UIDefines.ID_FORM_LOGININSTALLPOP
end

function Form_LoginInstallPopUI:GetFramePrefabName()
  return "Form_LoginInstallPop"
end

return Form_LoginInstallPopUI
