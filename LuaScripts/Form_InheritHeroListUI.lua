local Form_InheritHeroListUI = class("Form_InheritHeroListUI", require("UI/Common/UIBase"))

function Form_InheritHeroListUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_InheritHeroListUI:GetID()
  return UIDefines.ID_FORM_INHERITHEROLIST
end

function Form_InheritHeroListUI:GetFramePrefabName()
  return "Form_InheritHeroList"
end

return Form_InheritHeroListUI
