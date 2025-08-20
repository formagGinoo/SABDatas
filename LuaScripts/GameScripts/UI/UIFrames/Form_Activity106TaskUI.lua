local Form_Activity106TaskUI = class("Form_Activity106TaskUI", require("UI/Common/HeroActBase/UIHeroActTaskBase"))

function Form_Activity106TaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity106TaskUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY106TASK
end

function Form_Activity106TaskUI:GetFramePrefabName()
  return "Form_Activity106Task"
end

return Form_Activity106TaskUI
