local Form_Activity105TaskUI = class("Form_Activity105TaskUI", require("UI/Common/HeroActBase/UIHeroActTaskBase"))

function Form_Activity105TaskUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105TaskUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105TASK
end

function Form_Activity105TaskUI:GetFramePrefabName()
  return "Form_Activity105Task"
end

return Form_Activity105TaskUI
