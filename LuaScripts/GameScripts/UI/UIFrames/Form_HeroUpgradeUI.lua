local Form_HeroUpgradeUI = class("Form_HeroUpgradeUI", require("UI/Common/UIBase"))

function Form_HeroUpgradeUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroUpgradeUI:GetID()
  return UIDefines.ID_FORM_HEROUPGRADE
end

function Form_HeroUpgradeUI:GetFramePrefabName()
  return "Form_HeroUpgrade"
end

return Form_HeroUpgradeUI
