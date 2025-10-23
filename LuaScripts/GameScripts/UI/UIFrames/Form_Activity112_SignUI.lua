local Form_Activity112_SignUI = class("Form_Activity112_SignUI", require("UI/Common/HeroActBase/UIHeroActSignBase"))

function Form_Activity112_SignUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity112_SignUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY112_SIGN
end

function Form_Activity112_SignUI:GetFramePrefabName()
  return "Form_Activity112_Sign"
end

return Form_Activity112_SignUI
