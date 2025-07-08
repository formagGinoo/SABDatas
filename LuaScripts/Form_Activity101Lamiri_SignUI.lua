local Form_Activity101Lamiri_SignUI = class("Form_Activity101Lamiri_SignUI", require("UI/Common/HeroActBase/UIHeroActSignBase"))

function Form_Activity101Lamiri_SignUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101Lamiri_SignUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIRI_SIGN
end

function Form_Activity101Lamiri_SignUI:GetFramePrefabName()
  return "Form_Activity101Lamiri_Sign"
end

return Form_Activity101Lamiri_SignUI
