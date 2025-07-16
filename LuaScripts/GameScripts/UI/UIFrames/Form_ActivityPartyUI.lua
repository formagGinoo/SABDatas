local Form_ActivityPartyUI = class("Form_ActivityPartyUI", require("UI/Common/UIBase"))

function Form_ActivityPartyUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityPartyUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYPARTY
end

function Form_ActivityPartyUI:GetFramePrefabName()
  return "Form_ActivityParty"
end

return Form_ActivityPartyUI
