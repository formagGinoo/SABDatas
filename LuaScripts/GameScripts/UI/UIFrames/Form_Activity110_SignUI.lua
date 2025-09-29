local Form_Activity110_SignUI = class("Form_Activity110_SignUI", require("UI/Common/HeroActBase/UIHeroActSignBase"))

function Form_Activity110_SignUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110_SignUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110_SIGN
end

function Form_Activity110_SignUI:GetFramePrefabName()
  return "Form_Activity110_Sign"
end

return Form_Activity110_SignUI
