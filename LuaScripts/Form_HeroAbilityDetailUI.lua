local Form_HeroAbilityDetailUI = class("Form_HeroAbilityDetailUI", require("UI/Common/UIBase"))

function Form_HeroAbilityDetailUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroAbilityDetailUI:GetID()
  return UIDefines.ID_FORM_HEROABILITYDETAIL
end

function Form_HeroAbilityDetailUI:GetFramePrefabName()
  return "Form_HeroAbilityDetail"
end

return Form_HeroAbilityDetailUI
