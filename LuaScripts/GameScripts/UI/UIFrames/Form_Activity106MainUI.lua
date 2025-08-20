local Form_Activity106MainUI = class("Form_Activity106MainUI", require("UI/Common/HeroActBase/UIHeroActMainBase"))

function Form_Activity106MainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity106MainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY106MAIN
end

function Form_Activity106MainUI:GetFramePrefabName()
  return "Form_Activity106Main"
end

return Form_Activity106MainUI
