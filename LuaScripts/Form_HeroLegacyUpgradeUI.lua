local Form_HeroLegacyUpgradeUI = class("Form_HeroLegacyUpgradeUI", require("UI/Common/UIBase"))

function Form_HeroLegacyUpgradeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroLegacyUpgradeUI:GetID()
  return UIDefines.ID_FORM_HEROLEGACYUPGRADE
end

function Form_HeroLegacyUpgradeUI:GetFramePrefabName()
  return "Form_HeroLegacyUpgrade"
end

return Form_HeroLegacyUpgradeUI
