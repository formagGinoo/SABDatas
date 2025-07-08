local Form_HeroShowUI = class("Form_HeroShowUI", require("UI/Common/UIBase"))

function Form_HeroShowUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroShowUI:GetID()
  return UIDefines.ID_FORM_HEROSHOW
end

function Form_HeroShowUI:GetFramePrefabName()
  return "Form_HeroShow"
end

return Form_HeroShowUI
