local Form_HeroBreakThroughUI = class("Form_HeroBreakThroughUI", require("UI/Common/UIBase"))

function Form_HeroBreakThroughUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroBreakThroughUI:GetID()
  return UIDefines.ID_FORM_HEROBREAKTHROUGH
end

function Form_HeroBreakThroughUI:GetFramePrefabName()
  return "Form_HeroBreakThrough"
end

return Form_HeroBreakThroughUI
