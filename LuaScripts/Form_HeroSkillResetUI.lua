local Form_HeroSkillResetUI = class("Form_HeroSkillResetUI", require("UI/Common/UIBase"))

function Form_HeroSkillResetUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroSkillResetUI:GetID()
  return UIDefines.ID_FORM_HEROSKILLRESET
end

function Form_HeroSkillResetUI:GetFramePrefabName()
  return "Form_HeroSkillReset"
end

return Form_HeroSkillResetUI
