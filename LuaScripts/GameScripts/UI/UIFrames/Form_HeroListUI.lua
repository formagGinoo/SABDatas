local Form_HeroListUI = class("Form_HeroListUI", require("UI/Common/UIBase"))

function Form_HeroListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroListUI:GetID()
  return UIDefines.ID_FORM_HEROLIST
end

function Form_HeroListUI:GetFramePrefabName()
  return "Form_HeroList"
end

return Form_HeroListUI
