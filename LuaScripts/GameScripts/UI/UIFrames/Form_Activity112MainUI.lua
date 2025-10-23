local Form_Activity112MainUI = class("Form_Activity112MainUI", require("UI/Common/HeroActBase/UIHeroActMainBase"))

function Form_Activity112MainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity112MainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY112MAIN
end

function Form_Activity112MainUI:GetFramePrefabName()
  return "Form_Activity112Main"
end

return Form_Activity112MainUI
