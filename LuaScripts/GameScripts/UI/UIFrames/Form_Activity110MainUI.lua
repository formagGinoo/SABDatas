local Form_Activity110MainUI = class("Form_Activity110MainUI", require("UI/Common/HeroActBase/UIHeroActMainBase"))

function Form_Activity110MainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity110MainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY110MAIN
end

function Form_Activity110MainUI:GetFramePrefabName()
  return "Form_Activity110Main"
end

return Form_Activity110MainUI
