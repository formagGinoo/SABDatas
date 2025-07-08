local Form_HeroLegacyItemTipsUI = class("Form_HeroLegacyItemTipsUI", require("UI/Common/UIBase"))

function Form_HeroLegacyItemTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroLegacyItemTipsUI:GetID()
  return UIDefines.ID_FORM_HEROLEGACYITEMTIPS
end

function Form_HeroLegacyItemTipsUI:GetFramePrefabName()
  return "Form_HeroLegacyItemTips"
end

return Form_HeroLegacyItemTipsUI
