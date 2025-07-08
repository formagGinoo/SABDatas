local Form_PersonalRaidScoutCompletedUI = class("Form_PersonalRaidScoutCompletedUI", require("UI/Common/UIBase"))

function Form_PersonalRaidScoutCompletedUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_PersonalRaidScoutCompletedUI:GetID()
  return UIDefines.ID_FORM_PERSONALRAIDSCOUTCOMPLETED
end

function Form_PersonalRaidScoutCompletedUI:GetFramePrefabName()
  return "Form_PersonalRaidScoutCompleted"
end

return Form_PersonalRaidScoutCompletedUI
