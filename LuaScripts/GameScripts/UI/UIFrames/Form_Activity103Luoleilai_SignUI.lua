local Form_Activity103Luoleilai_SignUI = class("Form_Activity103Luoleilai_SignUI", require("UI/Common/HeroActBase/UIHeroActSignBase"))

function Form_Activity103Luoleilai_SignUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity103Luoleilai_SignUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY103LUOLEILAI_SIGN
end

function Form_Activity103Luoleilai_SignUI:GetFramePrefabName()
  return "Form_Activity103Luoleilai_Sign"
end

return Form_Activity103Luoleilai_SignUI
