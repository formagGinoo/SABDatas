local Form_HeroPreviewUI = class("Form_HeroPreviewUI", require("UI/Common/UIBase"))

function Form_HeroPreviewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroPreviewUI:GetID()
  return UIDefines.ID_FORM_HEROPREVIEW
end

function Form_HeroPreviewUI:GetFramePrefabName()
  return "Form_HeroPreview"
end

return Form_HeroPreviewUI
