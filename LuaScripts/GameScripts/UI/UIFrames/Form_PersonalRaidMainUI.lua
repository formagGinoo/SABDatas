local Form_PersonalRaidMainUI = class("Form_PersonalRaidMainUI", require("UI/Common/UIBase"))

function Form_PersonalRaidMainUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidMainUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDMAIN
end

function Form_PersonalRaidMainUI:GetFramePrefabName()
  return "Form_PersonalRaidMain"
end

return Form_PersonalRaidMainUI
