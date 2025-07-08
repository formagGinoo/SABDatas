local Form_HeroDetailUI = class("Form_HeroDetailUI", require("UI/Common/UIBase"))

function Form_HeroDetailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroDetailUI:GetID()
  return UIDefines.ID_FORM_HERODETAIL
end

function Form_HeroDetailUI:GetFramePrefabName()
  return "Form_HeroDetail"
end

return Form_HeroDetailUI
