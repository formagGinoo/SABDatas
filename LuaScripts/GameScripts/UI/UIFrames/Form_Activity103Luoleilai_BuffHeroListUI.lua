local Form_Activity103Luoleilai_BuffHeroListUI = class("Form_Activity103Luoleilai_BuffHeroListUI", require("UI/Common/HeroActBase/UIHeroActBuffHeroListBase"))

function Form_Activity103Luoleilai_BuffHeroListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity103Luoleilai_BuffHeroListUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_BUFFHEROLIST
end

function Form_Activity103Luoleilai_BuffHeroListUI:GetFramePrefabName()
  return "Form_Activity103Luoleilai_BuffHeroList"
end

return Form_Activity103Luoleilai_BuffHeroListUI
