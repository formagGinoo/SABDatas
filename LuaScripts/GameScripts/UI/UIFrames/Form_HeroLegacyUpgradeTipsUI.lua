local Form_HeroLegacyUpgradeTipsUI = class("Form_HeroLegacyUpgradeTipsUI", require("UI/Common/UIBase"))

function Form_HeroLegacyUpgradeTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroLegacyUpgradeTipsUI:GetID()
  return UIDefines.ID_FORM_HEROLEGACYUPGRADETIPS
end

function Form_HeroLegacyUpgradeTipsUI:GetFramePrefabName()
  return "Form_HeroLegacyUpgradeTips"
end

return Form_HeroLegacyUpgradeTipsUI
