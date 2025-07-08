local Form_ActivityFourteendaysFaceUI = class("Form_ActivityFourteendaysFaceUI", require("UI/Common/UIBase"))

function Form_ActivityFourteendaysFaceUI:Init(gameObject, csui)
  if gameObject == nil then
    return
  end
  self.m_csui = csui
  CS.UI.UILuaHelper.BindViewObjects(self, self.m_csui)
end

function Form_ActivityFourteendaysFaceUI:GetID()
  return UIDefines.ID_FORM_ACTIVITYFOURTEENDAYSFACE
end

function Form_ActivityFourteendaysFaceUI:GetFramePrefabName()
  return "Form_ActivityFourteendaysFace"
end

return Form_ActivityFourteendaysFaceUI
