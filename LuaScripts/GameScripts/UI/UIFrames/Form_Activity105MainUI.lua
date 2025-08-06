local Form_Activity105MainUI = class("Form_Activity105MainUI", require("UI/Common/HeroActBase/UIHeroActMainBase"))

function Form_Activity105MainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity105MainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY105MAIN
end

function Form_Activity105MainUI:GetFramePrefabName()
  return "Form_Activity105Main"
end

return Form_Activity105MainUI
