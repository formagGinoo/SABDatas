local Form_HeroBreakThroughPopUI = class("Form_HeroBreakThroughPopUI", require("UI/Common/UIBase"))

function Form_HeroBreakThroughPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroBreakThroughPopUI:GetID()
  return UIDefines.ID_FORM_HEROBREAKTHROUGHPOP
end

function Form_HeroBreakThroughPopUI:GetFramePrefabName()
  return "Form_HeroBreakThroughPop"
end

return Form_HeroBreakThroughPopUI
