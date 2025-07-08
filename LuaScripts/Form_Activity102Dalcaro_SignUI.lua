local Form_Activity102Dalcaro_SignUI = class("Form_Activity102Dalcaro_SignUI", require("UI/Common/HeroActBase/UIHeroActSignBase"))

function Form_Activity102Dalcaro_SignUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102Dalcaro_SignUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCARO_SIGN
end

function Form_Activity102Dalcaro_SignUI:GetFramePrefabName()
  return "Form_Activity102Dalcaro_Sign"
end

return Form_Activity102Dalcaro_SignUI
