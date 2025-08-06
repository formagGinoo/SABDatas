local Form_Activity105_SignUI = class("Form_Activity105_SignUI", require("UI/Common/HeroActBase/UIHeroActSignBase"))

function Form_Activity105_SignUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105_SignUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105_SIGN
end

function Form_Activity105_SignUI:GetFramePrefabName()
  return "Form_Activity105_Sign"
end

return Form_Activity105_SignUI
