local Form_HeroSkillPreviewUI = class("Form_HeroSkillPreviewUI", require("UI/Common/UIBase"))

function Form_HeroSkillPreviewUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroSkillPreviewUI:GetID()
  return UIDefines.ID_FORM_HEROSKILLPREVIEW
end

function Form_HeroSkillPreviewUI:GetFramePrefabName()
  return "Form_HeroSkillPreview"
end

return Form_HeroSkillPreviewUI
