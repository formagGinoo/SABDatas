local Form_HeroLegacyChangeUI = class("Form_HeroLegacyChangeUI", require("UI/Common/UIBase"))

function Form_HeroLegacyChangeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroLegacyChangeUI:GetID()
  return UIDefines.ID_FORM_HEROLEGACYCHANGE
end

function Form_HeroLegacyChangeUI:GetFramePrefabName()
  return "Form_HeroLegacyChange"
end

return Form_HeroLegacyChangeUI
