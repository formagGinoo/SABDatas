local Form_HeroLegacyTipsUI = class("Form_HeroLegacyTipsUI", require("UI/Common/UIBase"))

function Form_HeroLegacyTipsUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroLegacyTipsUI:GetID()
  return UIDefines.ID_FORM_HEROLEGACYTIPS
end

function Form_HeroLegacyTipsUI:GetFramePrefabName()
  return "Form_HeroLegacyTips"
end

return Form_HeroLegacyTipsUI
