local Form_Activity101LamiaMainUI = class("Form_Activity101LamiaMainUI", require("UI/Common/HeroActBase/UIHeroActMainBase"))

function Form_Activity101LamiaMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity101LamiaMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY101LAMIAMAIN
end

function Form_Activity101LamiaMainUI:GetFramePrefabName()
  return "Form_Activity101LamiaMain"
end

return Form_Activity101LamiaMainUI
