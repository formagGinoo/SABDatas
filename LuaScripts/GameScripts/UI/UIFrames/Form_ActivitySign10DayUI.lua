local Form_ActivitySign10DayUI = class("Form_ActivitySign10DayUI", require("UI/Common/UIBase"))

function Form_ActivitySign10DayUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivitySign10DayUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYSIGN10DAY
end

function Form_ActivitySign10DayUI:GetFramePrefabName()
  return "Form_ActivitySign10Day"
end

return Form_ActivitySign10DayUI
