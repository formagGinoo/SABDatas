local Form_HeroCareerDetailUI = class("Form_HeroCareerDetailUI", require("UI/Common/UIBase"))

function Form_HeroCareerDetailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroCareerDetailUI:GetID()
  return UIDefines.ID_FORM_HEROCAREERDETAIL
end

function Form_HeroCareerDetailUI:GetFramePrefabName()
  return "Form_HeroCareerDetail"
end

return Form_HeroCareerDetailUI
