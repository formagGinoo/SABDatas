local Form_HuntingNightUI = class("Form_HuntingNightUI", require("UI/Common/UIBase"))

function Form_HuntingNightUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_HuntingNightUI:GetID()
  return UIDefines.ID_FORM_HUNTINGNIGHT
end

function Form_HuntingNightUI:GetFramePrefabName()
  return "Form_HuntingNight"
end

return Form_HuntingNightUI
