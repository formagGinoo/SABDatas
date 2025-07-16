local Form_Activity101Lamia_BuffHeroListUI = class("Form_Activity101Lamia_BuffHeroListUI", require("UI/Common/HeroActBase/UIHeroActBuffHeroListBase"))

function Form_Activity101Lamia_BuffHeroListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamia_BuffHeroListUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIA_BUFFHEROLIST
end

function Form_Activity101Lamia_BuffHeroListUI:GetFramePrefabName()
  return "Form_Activity101Lamia_BuffHeroList"
end

return Form_Activity101Lamia_BuffHeroListUI
