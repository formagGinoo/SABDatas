local Form_Activity108MainUI = class("Form_Activity108MainUI", require("UI/Common/HeroActBase/UIHeroActMainSecondBase"))

function Form_Activity108MainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity108MainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY108MAIN
end

function Form_Activity108MainUI:GetFramePrefabName()
  return "Form_Activity108Main"
end

return Form_Activity108MainUI
