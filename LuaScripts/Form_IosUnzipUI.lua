local Form_IosUnzipUI = class("Form_IosUnzipUI", require("UI/Common/UIBase"))

function Form_IosUnzipUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_IosUnzipUI:GetID()
  return UIDefines.ID_FORM_IOSUNZIP
end

function Form_IosUnzipUI:GetFramePrefabName()
  return "Form_IosUnzip"
end

return Form_IosUnzipUI
