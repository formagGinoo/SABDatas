local Form_MainCityUI = class("Form_MainCityUI", require("UI/Common/UIBase"))

function Form_MainCityUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_MainCityUI:GetID()
  return UIDefines.ID_FORM_MAINCITY
end

function Form_MainCityUI:GetFramePrefabName()
  return "Form_MainCity"
end

return Form_MainCityUI
