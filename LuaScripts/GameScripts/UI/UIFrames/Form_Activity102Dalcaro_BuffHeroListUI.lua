local Form_Activity102Dalcaro_BuffHeroListUI = class("Form_Activity102Dalcaro_BuffHeroListUI", require("UI/Common/HeroActBase/UIHeroActBuffHeroListBase"))

function Form_Activity102Dalcaro_BuffHeroListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_BuffHeroListUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_BUFFHEROLIST
end

function Form_Activity102Dalcaro_BuffHeroListUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_BuffHeroList"
end

return Form_Activity102Dalcaro_BuffHeroListUI
