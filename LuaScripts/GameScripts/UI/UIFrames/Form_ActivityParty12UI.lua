local Form_ActivityParty12UI = class("Form_ActivityParty12UI", require("UI/Common/UIBase"))

function Form_ActivityParty12UI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityParty12UI:GetID()
  return UIDefines.ID_FORM_ACTIVITYPARTY12
end

function Form_ActivityParty12UI:GetFramePrefabName()
  return "Form_ActivityParty12"
end

return Form_ActivityParty12UI
