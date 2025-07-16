local Form_Activity102DalcaroMainUI = class("Form_Activity102DalcaroMainUI", require("UI/Common/HeroActBase/UIHeroActMainBase"))

function Form_Activity102DalcaroMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity102DalcaroMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY102DALCAROMAIN
end

function Form_Activity102DalcaroMainUI:GetFramePrefabName()
  return "Form_Activity102DalcaroMain"
end

return Form_Activity102DalcaroMainUI
