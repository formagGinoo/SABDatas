local Form_HeroHaloTipsPopUI = class("Form_HeroHaloTipsPopUI", require("UI/Common/UIBase"))

function Form_HeroHaloTipsPopUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HeroHaloTipsPopUI:GetID()
  return UIDefines.ID_FORM_HEROHALOTIPSPOP
end

function Form_HeroHaloTipsPopUI:GetFramePrefabName()
  return "Form_HeroHaloTipsPop"
end

return Form_HeroHaloTipsPopUI
