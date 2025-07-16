local Form_Activity103LuoleilaiMainUI = class("Form_Activity103LuoleilaiMainUI", require("UI/Common/HeroActBase/UIHeroActMainBase"))

function Form_Activity103LuoleilaiMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_Activity103LuoleilaiMainUI:GetID()
  return UIDefines.ID_FORM_ACTIVITY103LUOLEILAIMAIN
end

function Form_Activity103LuoleilaiMainUI:GetFramePrefabName()
  return "Form_Activity103LuoleilaiMain"
end

return Form_Activity103LuoleilaiMainUI
