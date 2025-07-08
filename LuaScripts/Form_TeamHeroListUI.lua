local Form_TeamHeroListUI = class("Form_TeamHeroListUI", require("UI/Common/UIBase"))

function Form_TeamHeroListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_TeamHeroListUI:GetID()
  return UIDefines.ID_FORM_TEAMHEROLIST
end

function Form_TeamHeroListUI:GetFramePrefabName()
  return "Form_TeamHeroList"
end

return Form_TeamHeroListUI
