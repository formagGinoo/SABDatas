local Form_GuidePicturreUI = class("Form_GuidePicturreUI", require("UI/Common/UIBase"))

function Form_GuidePicturreUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_GuidePicturreUI:GetID()
  return UIDefines.ID_FORM_GUIDEPICTURRE
end

function Form_GuidePicturreUI:GetFramePrefabName()
  return "Form_GuidePicturre"
end

return Form_GuidePicturreUI
