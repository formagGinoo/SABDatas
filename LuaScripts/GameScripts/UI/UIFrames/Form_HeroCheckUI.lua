local Form_HeroCheckUI = class("Form_HeroCheckUI", require("UI/Common/UIBase"))

function Form_HeroCheckUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroCheckUI:GetID()
  return UIDefines.ID_FORM_HEROCHECK
end

function Form_HeroCheckUI:GetFramePrefabName()
  return "Form_HeroCheck"
end

return Form_HeroCheckUI
